import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:surveyapp/data/models/form.dart';
import 'package:surveyapp/data/models/page.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/data/network_services/form.dart';
import 'package:surveyapp/data/network_services/network_client/dio_client.dart';
import 'package:surveyapp/data/repositories/stream_state/form_submit_state.dart';
import 'package:video_compress/video_compress.dart';

class FormRepository {
  final FormNetworkService formNetworkService;

  FormRepository({required this.formNetworkService});

  Future<dynamic> getFormDetails(String sid) async {
    Map data = await formNetworkService.getFormData(sid);

    if (data['success']) {
      SurveyForm form = SurveyForm.fromJson(data);
      form.sid = sid;
      return form;
    } else {
      return data;
    }
  }

  Stream<FormSubmitState> submitForm(SurveyForm form) {
    final StreamController<FormSubmitState> controller =
        StreamController<FormSubmitState>();
    runSubmitFormTask(controller: controller, form: form);
    return controller.stream;
  }

  Future<void> runSubmitFormTask(
      {required StreamController controller, required SurveyForm form}) async {
    controller.add(NewFormSubmission(form: form));
    for (PageData page in form.pages) {
      for (Question question in page.questions) {
        if (question is ImageQuestion) {
          for (FileData image in question.imageList) {
            if (image.id == null || image.id!.isEmpty) {
              controller.add(FormSubmitting(form: form));

              try {
                FormData formData = FormData.fromMap({
                  'file': await MultipartFile.fromFile(
                    image.address,
                    filename: basename(image.address),
                  ),
                });

                var response = await (await DioClient.dio).post(
                  '/audit/upload/image',
                  queryParameters: {
                    'filename': basename(image.address),
                    'resolution': 'medium',
                  },
                  data: formData,
                );

                if (response.statusCode == 200) {
                  var data = response.data;

                  image.id = data['id'];
                  image.uploadStatus = UploadStatus.UPLOADED;
                  controller.add(FormSubmitting(form: form));
                } else {
                  image.uploadStatus = UploadStatus.ERROR;
                  controller.add(FileUploadError(
                    form: form,
                    error: "Upload failed with status ${response.statusCode}",
                  ));
                }
              } on DioException catch (e) {
                image.uploadStatus = UploadStatus.ERROR;
                controller.add(FileUploadError(
                  form: form,
                  error: e.response?.data['msg'] ?? "Upload failed",
                ));
              } catch (e) {
                image.uploadStatus = UploadStatus.ERROR;
                controller.add(FileUploadError(
                  form: form,
                  error: "Unexpected error occurred",
                ));
              }
            } else {
              image.uploadStatus = UploadStatus.UPLOADED;
              controller.add(FormSubmitting(form: form));
            }
          }
        }

        if (question is VideoQuestion) {
          for (FileData video in question.videoList) {
            if (video.id == null || video.id!.isEmpty) {
              controller.add(FormSubmitting(form: form));

              try {
                FormData formData = FormData.fromMap({
                  'file': await MultipartFile.fromFile(
                    video.address,
                    filename: basename(video.address),
                  ),
                });

                var response = await (await DioClient.dio).post(
                  '/audit/upload/video',
                  queryParameters: {
                    'filename': basename(video.address),
                  },
                  data: formData,
                );

                if (response.statusCode == 200) {
                  var data = response.data;
                  video.id = data['id'];
                  video.uploadStatus = UploadStatus.UPLOADED;
                  controller.add(FormSubmitting(form: form));
                } else {
                  video.uploadStatus = UploadStatus.ERROR;
                  controller.add(FileUploadError(
                    form: form,
                    error: "Upload failed with status ${response.statusCode}",
                  ));
                }
              } on DioException catch (e) {
                video.uploadStatus = UploadStatus.ERROR;

                // 👇 Add these print statements for debugging:
                print('DioException caught!');
                print('Error message: ${e.message}');
                print('Error response: ${e.response}');
                print('Error response data: ${e.response?.data}');
                print('Error response status code: ${e.response?.statusCode}');

                String errorMessage = "Upload failed";

                if (e.response?.data is Map && e.response?.data['msg'] != null) {
                  errorMessage = e.response!.data['msg'];
                } else if (e.response?.data is String) {
                  errorMessage = e.response!.data;
                }

                controller.add(FileUploadError(
                  form: form,
                  error: errorMessage,
                ));
            } catch (e) {
                video.uploadStatus = UploadStatus.ERROR;
                controller.add(FileUploadError(
                  form: form,
                  error: "Unexpected error occurred",
                ));
              }
            } else {
              video.uploadStatus = UploadStatus.UPLOADED;
              controller.add(FormSubmitting(form: form));
            }
          }
        }
      }
    }

    // await Future.delayed(Duration(seconds: 5));
    if (_verifySubmit(form: form)) {
      Map formJson = SurveyForm.toJson(form);
      Map? data = await formNetworkService.submitForm(formJson);

      if (data['success']) {
        controller.add(FormSubmitted(form: form));
      } else {
        controller.add(FormSubmitError(form: form, error: data['error']));
      }
    } else {
      controller.add(FormSubmitError(
          form: form,
          error: "All Media Files not Submitted Successfully, retry again !!"));
    }

    controller.done;
    controller.close();
  }

  Future<bool> _uploadFile(
      {required FormData formData, required String url}) async {
    try {
      await Dio().post(url, data: formData);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _verifySubmit({required SurveyForm form}) {
    for (PageData page in form.pages) {
      for (Question question in page.questions) {
        if (question is ImageQuestion) {
          for (FileData image in question.imageList) {
            print(question);
            if (image.id == null || image.id!.isEmpty) {
              return false;
            }
          }
        }

        if (question is VideoQuestion) {
          for (FileData video in question.videoList) {
            if (video.id == null || video.id!.isEmpty) {
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  void cannotUploadFile(
      {required String sid,
      required String cycleId,
      required String qid,
      required String reason}) {
    formNetworkService.cannotUploadFile({
      "storeId": sid,
      "cycleId": cycleId,
      "questionId": qid,
      "reason": reason
    });
  }

  Future<File?> compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );
    return info?.file;
  }

}
