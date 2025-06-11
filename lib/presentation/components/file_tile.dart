import 'package:surveyapp/data/models/question.dart';
import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:path/path.dart';

class FileTile extends StatelessWidget {
  final FileData file;

  const FileTile({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Widget icon = Icon(
      Icons.upload_file,
      size: 20,
    );

    if (file.id == null || file.id!.isEmpty) {
      if (file.uploadStatus == UploadStatus.UPLOADING) {
        icon = SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.greenAccent,
          ),
        );
      } else if (file.uploadStatus == UploadStatus.ERROR) {
        icon = Icon(
          Icons.upload_file,
          color: Colors.redAccent,
          size: 20,
        );
      }
    } else if (file.uploadStatus == UploadStatus.UPLOADED) {
      icon = Icon(
        Icons.upload_file,
        color: Colors.greenAccent,
        size: 20,
      );
    }

    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: cPrimary.withAlpha(100),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    basename(file.address),
                    maxLines: 5,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 15),
                  Text(
                    dirname(file.address),
                    maxLines: 5,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: cPrimary,
              ),
              child: icon),
        ],
      ),
    );
  }
}
