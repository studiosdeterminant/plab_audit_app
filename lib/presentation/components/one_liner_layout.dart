import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/data/models/question.dart';

class OneLinerQuestionLayout extends StatelessWidget {
  final OneLinerQuestion question;
  final onChangedListener;

  const OneLinerQuestionLayout(
      {Key? key, required this.question, required this.onChangedListener})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: TextFormField(
          key: Key(question.qid),
          onChanged: (text) => {question.answer = text},
          keyboardType: TextInputType.multiline,
          initialValue: question.answer,
          maxLines: null,
          cursorColor: cSecondary,
          validator: (value) {
            if (question.isRequired && (value == null || value.isEmpty)) {
              return "field required";
            }else {
              return null;
            }
          },
          decoration: InputDecoration(
            hintText: "Enter Answer ..",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
