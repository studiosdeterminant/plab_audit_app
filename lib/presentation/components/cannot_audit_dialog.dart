import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:image_editor/image_editor.dart' as ie;
import 'package:path/path.dart';

class CannotAuditDialog extends StatefulWidget {
  final cannotAudit;

  const CannotAuditDialog({Key? key, required this.cannotAudit}) : super(key: key);

  @override
  _CannotAuditDialogState createState() => _CannotAuditDialogState();

}

class _CannotAuditDialogState extends State<CannotAuditDialog> {
  int selected = -1;
  String img = "";

  final ImagePicker picker = new ImagePicker();
  final Location location = new Location();

  List<String> reasons = ['Auditing Not Allowed', 'Store Closed', 'Store Shifted',  'Store Under Renovation', 'Outside Geographic Region'];

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = reasons.map<Widget>((reason){
      return InkWell(
        onTap: (){
          setState((){
            selected = reasons.indexOf(reason, 0);
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (selected == reasons.indexOf(reason, 0) ? Colors.amber : cPrimary)
          ),
          child: Text(reason, style: TextStyle(color: cWhite, fontSize: 12)),
        ),
      );
    }).toList();

    widgets.add(
      Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  child: Text('Add Image', style: TextStyle(color: cWhite, fontSize: 10)),
                  onPressed: () {
                    _takePicture(context);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: cSecondary,
                      backgroundColor: cSecondary,
                      elevation: 3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            img.isNotEmpty ?
              SizedBox(
                height: 250,
                child: imageTile(
                  context: context,
                  image: img,
                  onDelete: () => {
                    setState((){
                      img = "";
                    })
                  },
                ),
              )
            : SizedBox(height: 10),
          ],
        ),
      )
    );
    return AlertDialog(
      title: Text('Reason for not Auditing', style: TextStyle(fontSize: 15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text('Send', style: TextStyle(color: cWhite)),
          onPressed: () {

            if(selected == -1) {
              Fluttertoast.showToast(msg: "Select a reason first !!");
            } else if([0,1,2,3].contains(selected) && img.isEmpty){
              Fluttertoast.showToast(msg: "Add Image To Submit");
            }else {
              widget.cannotAudit(reason: reasons[selected], image: img);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: cSecondary,
              backgroundColor: cSecondary,
              elevation: 3),
        ),
        ElevatedButton(
          child: Text('Cancel', style: TextStyle(color: cWhite)),
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: cSecondary,
              backgroundColor: cSecondary,
              elevation: 3),
        ),
      ],
    );
  }

  Widget imageTile(
      {required context, required String image, required onDelete}) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.95,
      margin: EdgeInsets.only(top: 2),
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

  void _takePicture(context) async {
    try {
      final XFile? pickedFile =
      await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null)
        throw TypeError();
      else
        _saveImage(pickedFile, context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Picking File",
          gravity: ToastGravity.BOTTOM);
    }
  }

  void _saveImage(XFile pickedFile, context) async {
    try {
      final String path = (await getApplicationDocumentsDirectory()).path;
      File image = File(pickedFile.path);
      // options.

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

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
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          Fluttertoast.showToast(
              msg: "Provide Location Permission and try again",
              gravity: ToastGravity.BOTTOM);
          return;
        }
      }

      Fluttertoast.showToast(
          msg: "Fetching Location Data", gravity: ToastGravity.BOTTOM);
      _locationData = await location.getLocation();

      final ie.ImageEditorOption options = ie.ImageEditorOption();
      final textOptions = ie.AddTextOption();
      textOptions.addText(
        ie.EditorText(
          offset: Offset(2, 2),
          text:
          "The P Lab \n${_locationData.latitude}\n${_locationData.longitude} \n${DateTime.now()}",
          fontSizePx: 75,
          textColor: cWhite,
          fontName: '',
        ),
      );

      options.addOption(textOptions);
      options.outputFormat = const ie.OutputFormat.jpeg(50);

      final File savedImage = File("$path/${basename(image.path)}");
      savedImage.writeAsBytes((await ie.ImageEditor.editFileImage(
          file: image, imageEditorOption: options))!);

      setState(() {
        img = savedImage.path;
      });

    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error Occurred while Storing File",
          gravity: ToastGravity.BOTTOM);
    }
  }
}
