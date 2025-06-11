import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:surveyapp/data/network_services/network_client/dio_client.dart';
import 'package:surveyapp/helpers/strings.dart';

class FormNetworkService {
  final String baseUrl = BASE_URL;

  Future<Map> getFormData(sid) async {
    try {
      // await Future.delayed(Duration(milliseconds: 1000));
      // return {
      //   'success': true,
      //   'cycleId': 'fid12',
      //   'pages': [
      //     {
      //       'pid': 'pid1',
      //       'pageTitle': 'KuchTo page hai ye',
      //       'questions': [
      //         {
      //           'questionId': 'questionId2',
      //           'questionTitle': 'How Idiot Am I ?',
      //           'answerType': 'numeric',
      //           'isRequired': 'true',
      //         }
      //         ,
      //         {
      //           'questionId': 'questionId3',
      //           'questionTitle': 'Explain in brief why I am an Idiot ?',
      //           'answerType': 'text',
      //           'isRequired': 'true',
      //         },
      //         {
      //           'questionId': 'questionId1',
      //           'questionTitle': 'Am I an Idiot ?',
      //           'answerType': 'single',
      //           'answerOptions': ['Yes', 'No'],
      //           'isRequired': 'true',
      //         },
      //         {
      //           'questionId': 'questionId4',
      //           'questionTitle': 'How idiotic is the place ?',
      //           'answerType': 'image',
      //           'isRequired': 'true',
      //         }
      //       ]
      //     },
      //     // {
      //     //   'pid': 'pid2',
      //     //   'pageTitle': 'KuchTo page hai ye',
      //     //   'questions': [
      //     //     {
      //     //       'questionId': 'questionId2',
      //     //       'questionTitle': 'How Idiot Am I ?',
      //     //       'answerType': 'numeric',
      //     //       'isRequired': 'true',
      //     //     },
      //     //     {
      //     //       'questionId': 'questionId1',
      //     //       'questionTitle': 'Am I an Idiot ?',
      //     //       'answerType': 'single',
      //     //       'answerOptions': ['Yes', 'No'],
      //     //       'isRequired': 'true',
      //     //     },
      //     //     {
      //     //       'questionId': 'questionId3',
      //     //       'questionTitle': 'Explain in brief why I am an Idiot ?',
      //     //       'answerType': 'text',
      //     //       'isRequired': 'true',
      //     //     }
      //     //   ]
      //     // },
      //     // {
      //     //   'pid': 'pid3',
      //     //   'pageTitle': 'KuchTo page hai ye',
      //     //   'questions': [
      //     //     {
      //     //       'questionId': 'questionId2',
      //     //       'questionTitle': 'How Idiot Am I ?',
      //     //       'answerType': 'numeric',
      //     //       'isRequired': 'true',
      //     //     },
      //     //     {
      //     //       'questionId': 'questionId1',
      //     //       'questionTitle': 'Am I an Idiot ?',
      //     //       'answerType': 'single',
      //     //       'answerOptions': ['Yes', 'No'],
      //     //       'isRequired': 'true',
      //     //     },
      //     //     {
      //     //       'questionId': 'questionId3',
      //     //       'questionTitle': 'Explain in brief why I am an Idiot ?',
      //     //       'answerType': 'text',
      //     //       'isRequired': 'true',
      //     //     }
      //     //   ]
      //     // },
      //   ]
      // };

      var response = await (await DioClient.dio)
          .get(baseUrl + '/cycle/current', queryParameters: {'storeId': sid});

      Map data = response.data;
      data['success'] = true;
      return data;
    } on DioError catch (e) {
      if (e.response!.data is Map && e.response!.data.containsKey('msg')) {
        final Map data = {
          'success': false,
          'error': e.response!.data['msg'] ?? "Something went wrong",
        };
        return data;
      } else {
        return {'success': false, 'error': 'Something went wrong'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<Map> submitImage(String imageName) async {
    try {
      var response = await (await DioClient.dio).post('/audit/upload/image',
          queryParameters: {'filename': imageName});

      Map data = response.data;
      data['success'] = true;
      return data;
    } on DioException catch (e) {
      if (e.response != null) if (e.response!.data is Map &&
          e.response!.data.containsKey('msg')) {
        final Map data = {
          'success': false,
          'error': e.response!.data['msg'] ?? "Something went wrong",
        };
        return data;
      }

      return {'success': false, 'error': 'Something went wrong'};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<Map> submitVideo(String videoName) async {
    try {
      var response = await (await DioClient.dio).post(
        '/audit/upload/video',
        queryParameters: {'filename': videoName},
      );

      Map data = response.data;
      data['success'] = true;
      return data;
    } on DioException catch (e) {
      if (e.response != null) if (e.response!.data is Map &&
          e.response!.data.containsKey('msg')) {
        final Map data = {
          'success': false,
          'error': e.response!.data['msg'] ?? "Something went wrong",
        };
        return data;
      }

      return {'success': false, 'error': 'Something went wrong'};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<Map> submitForm(Map formJson) async {
    try {
      var response = await (await DioClient.dio)
          .post("/audit", data: jsonEncode(formJson));

      Map data = response.data;
      data['success'] = true;
      return data;
    } on DioException catch (e) {
      if (e.response != null) if (e.response!.data is Map &&
          e.response!.data.containsKey('msg')) {
        final Map data = {
          'success': false,
          'error': e.response!.data['msg'] ?? "Something went wrong",
        };
        return data;
      }

      return {'success': false, 'error': 'Something went wrong'};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  void cannotUploadFile(Map<String, String?> reason) async {
    try {
      Dio dio = await DioClient.dio;
      dio.post("/audit/cannot_question", data: jsonEncode(reason));
    } catch (e) {}
  }
}
