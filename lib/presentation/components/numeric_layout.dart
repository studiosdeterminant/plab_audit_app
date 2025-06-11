import 'package:flutter/material.dart';
import 'package:surveyapp/data/models/question.dart';

class NumericQuestionLayout extends StatelessWidget {
  final NumericChoiceQuestion question;
  final onChangedListener;

  const NumericQuestionLayout(
      {Key? key,
      required this.question,
      required this.onChangedListener,
      })
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
          // key: Key(question.qid),
          onChanged: onChangedListener,
          keyboardType: TextInputType.number,
          initialValue: question.answer?.toString() ?? "",
          validator: (value){
            if(question.isRequired && (value == null || value.isEmpty))
              return "field required";
            else
              return null;
          },
          decoration: InputDecoration(
            hintText: "Enter Score ..",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
