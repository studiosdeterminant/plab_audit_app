import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';

class QuestionContainer extends StatelessWidget {
  final Widget child;
  final String question;

  const QuestionContainer(
      {Key? key, required this.child, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: cPrimary.withOpacity(0.1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            maxLines: 3,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
          ),
          SizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }
}
