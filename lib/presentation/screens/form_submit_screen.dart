import 'package:flutter/material.dart';
import 'package:surveyapp/data/models/form.dart';
import 'package:surveyapp/data/models/page.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/presentation/components/file_tile.dart';

class FormSubmitScreen extends StatelessWidget {
  final SurveyForm form;

  const FormSubmitScreen({Key? key, required this.form})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<Widget> widgets = [];

    for (PageData page in form.pages) {
      for (Question question in page.questions) {
        if (question is ImageQuestion) {
          for (FileData image in question.imageList) {
            widgets.add(FileTile(
              file: image,
            ));
          }
        }

        if (question is VideoQuestion) {
          for (FileData video in question.videoList) {
            widgets.add(FileTile(
              file: video,
            ));
          }
        }
      }
    }

    widgets.add(Center(child: CircularProgressIndicator(color: cPrimary,)));

    return Container(
      width: size.width,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }
}
