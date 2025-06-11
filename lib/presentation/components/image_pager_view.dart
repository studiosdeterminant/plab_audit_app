import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_editor/image_editor.dart' as ie;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:surveyapp/cubits/images/images_cubit.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:location/location.dart' as loc;
import 'package:surveyapp/helpers/strings.dart';
import 'package:image/image.dart' as i;
import 'package:image/image.dart' show drawString, arial_24;
import 'package:geocoding/geocoding.dart';
import 'cannot_take_image.dart';
import 'package:surveyapp/presentation/screens/image_annotation_screen.dart';

@immutable
class ImagePager extends StatelessWidget {
  final onLocationFetched;

  ImagePager({Key? key, this.onLocationFetched}) : super(key: key);

  final ImagePicker picker = new ImagePicker();
  final loc.Location location = new loc.Location();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FormField(
      builder: (FormFieldState<ImageQuestion> state1) {
        return BlocBuilder<ImagesCubit, ImagesState>(
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
                        onPressed: () => _asyncInputDialog(context, (
                            {required String? reason}) {
                          BlocProvider.of<ImagesCubit>(context)
                              .cannotTakeImage(reason: reason);
                        }, state.question.reason),
                        child: Text(
                            state.question.reason == null
                                ? CANNOT_UPLOAD_TEXT
                                : state.question.reason!,
                            style: TextStyle(color: cWhite, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: cPrimary,
                            backgroundColor: cPrimary,
                            elevation: 3),
                      ),
                      ElevatedButton(
                        onPressed: () => {
                          _takePicture(context),
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
                          //           borderRadius:  BorderRadius.only(
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
                          //             //       _getImageFromGallery(context),
                          //             //     },
                          //             //     child: ListTile(
                          //             //       leading: Icon(
                          //             //         Icons.image_outlined,
                          //             //         size: 50,
                          //             //         color: cWhite,
                          //             //       ),
                          //             //       title: Text("Select Image from Gallery",
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
                          //                     Icons.camera_alt_outlined,
                          //                     size: 50,
                          //                     color: cWhite,
                          //                   ),
                          //                   title: Text("Take Picture",
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
                          "ADD IMAGE",
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
                            i < state.question.imageList.length;
                            i++)
                          imageTile(
                            context: context,
                            image: state.question.imageList[i].address,
                            onDelete: () => {
                              BlocProvider.of<ImagesCubit>(context)
                                  .deleteImage(imageIndex: i),
                            },
                          ),
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
      validator: (ImageQuestion? value) {
        if (value!.reason == null &&
            value.isRequired &&
            value.imageList.length == 0) {
          return "Field is Required !!";
        } else
          return null;
      },
    );
  }

  void _asyncInputDialog(
      BuildContext context, cannotTake, defaultReason) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return CannotTakeImageDialog(
            cannotTake: cannotTake, defaultReason: defaultReason);
      },
    );
  }

void _getImageFromGallery(context) async {
  try {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null)
      throw TypeError();
    else {
      final File file = File(pickedFile.path);
      // Navigate to annotation screen
      final annotatedBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnnotationScreen(imageFile: file),
        ),
      );
      if (annotatedBytes != null) {
        // Save the annotated image to a temp file
        final tempFile = await File('${file.parent.path}/annotated_${file.uri.pathSegments.last}')
            .writeAsBytes(annotatedBytes);
        _saveImage(XFile(tempFile.path), context);
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
        msg: "Error Occurred while Picking File",
        gravity: ToastGravity.BOTTOM);
  }
}

void _takePicture(context) async {
  try {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null)
      throw TypeError();
    else {
      final File file = File(pickedFile.path);
      // Navigate to annotation screen
      final annotatedBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnnotationScreen(imageFile: file),
        ),
      );
      if (annotatedBytes != null) {
        // Save the annotated image to a temp file
        final tempFile = await File('${file.parent.path}/annotated_${file.uri.pathSegments.last}')
            .writeAsBytes(annotatedBytes);
        _saveImage(XFile(tempFile.path), context);
      }
    }
  } catch (e) {
    Fluttertoast.showToast(
        msg: "Error Occurred while Picking File",
        gravity: ToastGravity.BOTTOM);
  }
}

  void _saveImage(XFile pickedFile, context) async {
    try {
      Fluttertoast.showToast(
          msg: "Saving File ...", gravity: ToastGravity.BOTTOM);

      final String path = (await getApplicationDocumentsDirectory()).path;
      File file = File(pickedFile.path);
      i.Image? image = i.decodeImage(file.readAsBytesSync());

      if (image == null) {
        throw TypeError();
      }

      var decodedImage = await decodeImageFromList(file.readAsBytesSync());

      if (decodedImage.height > decodedImage.width) {
        image = i.copyResize(image, height: 1280);
      } else {
        image = i.copyResize(image, width: 1280);
      }

      file.writeAsBytesSync(i.encodeJpg(image));

      bool _serviceEnabled;
      loc.PermissionStatus _permissionGranted;
      loc.LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          Fluttertoast.showToast(
              msg: "Enable Location Service for Storing Images and try again",
              gravity: ToastGravity.BOTTOM);
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          Fluttertoast.showToast(
              msg: "Provide Location Permission and try again",
              gravity: ToastGravity.BOTTOM);
          return;
        }
      }

      Fluttertoast.showToast(
          msg: "Fetching Location Data", gravity: ToastGravity.BOTTOM);
      _locationData = await location.getLocation();

      // Fetch address using geocoding
      String addressLine1 = "";
      String addressLine2 = "";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _locationData.latitude ?? 0.0,
          _locationData.longitude ?? 0.0,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          addressLine1 = "${placemark.name ?? ''}, ${placemark.street ?? ''}".trim();
          addressLine2 = "${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}".trim();
        }
      } catch (e) {
        addressLine1 = "Address not found";
        addressLine2 = "";
      }

      final ie.ImageEditorOption options = ie.ImageEditorOption();
      final textOptions = ie.AddTextOption();

      final String labelText =
        "The P Lab\n"
        "$addressLine1\n"
        "$addressLine2\n"
        "Lat: ${_locationData.latitude}, Lng: ${_locationData.longitude}\n"
        "${DateTime.now().toString().substring(0, 19)}";

      // Draw label at the bottom using the image package
      int fontSize = 24;
      int padding = 20;
      int lines = '\n'.allMatches(labelText).length + 1;
      int y = image.height - (fontSize * lines) - padding;

      // Draw a semi-transparent black rectangle as background for the text
      i.fillRect(
        image,
        0,
        y - 10,
        image.width,
        y + fontSize * lines + 10,
        i.getColor(0, 0, 0, 180),
      );

      // Draw the label text in white
      i.drawString(image, i.arial_24, padding, y, labelText, color: i.getColor(255,255,255));

      // Save the image
      file.writeAsBytesSync(i.encodeJpg(image, quality: 90));

      onLocationFetched(
          latitude: _locationData.latitude, longitude: _locationData.longitude);

      BlocProvider.of<ImagesCubit>(context).addImage(file.path);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Storing File",
          gravity: ToastGravity.BOTTOM);
    }
  }

  Widget imageTile(
      {required context, required String image, required onDelete}) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: EdgeInsets.only(right: 5, top: 2),
      decoration: BoxDecoration(
        color: cPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.file(
              File(image),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: onDelete,
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