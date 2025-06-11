import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:surveyapp/cubits/videos/videos_cubit.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/presentation/components/cannot_take_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

@immutable
class VideoPager extends StatelessWidget {
  VideoPager({Key? key}) : super(key: key);

  final ImagePicker picker = new ImagePicker();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FormField(
      builder: (FormFieldState<VideoQuestion> state1) {
        return BlocBuilder<VideosCubit, VideosState>(
          builder: (context, state) {
            state1.setValue(state.question);
            return Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: ()=> _asyncInputDialog(context, ({required String? reason}){
                            BlocProvider.of<VideosCubit>(context).cannotTakeVideo(reason: reason);
                          }, state.question.reason),
                          child: Text(state.question.reason == null ? CANNOT_UPLOAD_TEXT : state.question.reason!, style: TextStyle(color: cWhite, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: cPrimary,
                            backgroundColor: cPrimary,
                            elevation: 3),
                      ),
                      ElevatedButton(
                        onPressed: () => {
                          _takePicture(context)
                          // showModalBottomSheet(
                          //     context: context,
                          //     backgroundColor: Colors.transparent,
                          //     builder: (BuildContext context2) {
                          //       return Container(
                          //         height: size.height * 0.4,
                          //         padding: EdgeInsets.symmetric(
                          //             vertical: 5, horizontal: 15),
                          //         decoration: BoxDecoration(
                          //           color: cPrimary,
                          //           borderRadius: BorderRadius.only(
                          //               topLeft: Radius.circular(15),
                          //               topRight: Radius.circular(15)),
                          //         ),
                          //         child: Column(
                          //           children: [
                          //             Row(
                          //               mainAxisAlignment: MainAxisAlignment.end,
                          //               children: [
                          //                 Padding(
                          //                   padding: const EdgeInsets.symmetric(
                          //                       horizontal: 25, vertical: 8),
                          //                   child: InkWell(
                          //                     onTap: () => {Navigator.pop(context)},
                          //                     child: Icon(
                          //                       Icons.close,
                          //                       size: 25,
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //             // Card(
                          //             //   color: Colors.transparent,
                          //             //   elevation: 0,
                          //             //   shadowColor: Colors.transparent,
                          //             //   child: InkWell(
                          //             //     onTap: () => {
                          //             //       Navigator.pop(context),
                          //             //       _getVideoFromGallery(context),
                          //             //     },
                          //             //     child: ListTile(
                          //             //       leading: Icon(
                          //             //         Icons.video_call,
                          //             //         size: 50,
                          //             //         color: cWhite,
                          //             //       ),
                          //             //       title: Text("Select Video from Gallery",
                          //             //           style: TextStyle(color: cWhite)),
                          //             //     ),
                          //             //   ),
                          //             // ),
                          //             Card(
                          //               color: Colors.transparent,
                          //               elevation: 0,
                          //               shadowColor: Colors.transparent,
                          //               child: InkWell(
                          //                 onTap: () => {
                          //                   Navigator.pop(context),
                          //                   _takePicture(context),
                          //                 },
                          //                 child: ListTile(
                          //                   leading: Icon(
                          //                     Icons.video_call_outlined,
                          //                     size: 50,
                          //                     color: cWhite,
                          //                   ),
                          //                   title: Text("Take Video",
                          //                       style: TextStyle(color: cWhite)),
                          //                 ),
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //       );
                          //     })
                        },
                        child: Text(
                          "ADD VIDEO",
                          style: TextStyle(color: cWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: cSecondary,
                            backgroundColor: cSecondary,
                            elevation: 3),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (int i = 0;
                            i < state.question.videoList.length;
                            i++)
                          FutureBuilder<Widget>(
                            future: VideoTile(
                              context: context,
                              video: state.question.videoList[i].address,
                              onDelete: () => {
                                BlocProvider.of<VideosCubit>(context)
                                    .deleteVideo(videoIndex: i)
                              },
                            ),
                            builder: (BuildContext context,
                                AsyncSnapshot<Widget> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: cSecondary,
                                  ),
                                );
                              } else {
                                if (snapshot.hasError)
                                  return Center(
                                    child: Icon(Icons.warning_amber_outlined),
                                  );
                                else
                                  return snapshot.data!;
                              }
                            },
                          )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  state1.hasError
                      ? Text(state1.errorText ?? "",
                          style: TextStyle(color: Colors.red[400]))
                      : SizedBox(),
                ],
              ),
            );
          },
        );
      },
      validator: (VideoQuestion? value) {
        if (value!.reason == null && value.isRequired && value.videoList.length == 0) {
          return "Field is Required !!";
        } else
          return null;
      },
    );
  }

  void _asyncInputDialog(BuildContext context, cannotTake, defaultReason) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return CannotTakeImageDialog(cannotTake: cannotTake, defaultReason: defaultReason);
      },
    );
  }

  void _getVideoFromGallery(context) async {
    try {
      final XFile? pickedFile =
          await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null)
        throw TypeError();
      else
        _saveVideo(pickedFile, context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Picking File",
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _takePicture(context) async {
    try {
      final XFile? pickedFile =
          await picker.pickVideo(source: ImageSource.camera);

      if (pickedFile == null)
        throw TypeError();
      else
        _saveVideo(pickedFile, context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Picking File",
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _saveVideo(XFile pickedFile, context) async {
    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      File video = File(pickedFile.path);

      final File savedVideo = await video.copy("$path/${basename(video.path)}");

      BlocProvider.of<VideosCubit>(context).addVideo(savedVideo.path);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Storing File",
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<Widget> VideoTile(
      {required context, required String video, required onDelete}) async {
    Size size = MediaQuery.of(context).size;

    final thumbnail = await VideoThumbnail.thumbnailData(
        video: video, imageFormat: ImageFormat.PNG, maxHeight: 230);
    return Container(
      width: size.width,
      margin: EdgeInsets.only(right: 5, top: 2),
      decoration: BoxDecoration(
        color: cPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.memory(thumbnail!),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () => {onDelete()},
              child: Container(
                margin: EdgeInsets.only(top: 5, right: 5),
                decoration: BoxDecoration(
                  color: cWhite,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
