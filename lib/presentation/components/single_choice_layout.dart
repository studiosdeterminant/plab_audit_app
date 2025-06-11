import 'package:flutter/material.dart';
import 'package:surveyapp/data/models/question.dart';

class SingleChoiceQuestionLayout extends StatefulWidget {
  final SingleChoiceQuestion question;
  final onChangedListener;

  const SingleChoiceQuestionLayout({
    Key? key,
    required this.question,
    required this.onChangedListener,
  }) : super(key: key);

  @override
  _SingleChoiceQuestionLayoutState createState() =>
      _SingleChoiceQuestionLayoutState(selected: question.answer);
}

class _SingleChoiceQuestionLayoutState
    extends State<SingleChoiceQuestionLayout> {
  int? selected;

  _SingleChoiceQuestionLayoutState({required this.selected});

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState<bool> state) {

        if(selected != null && selected! >= 0 )
          state.setValue(true);

        return Column(
          children: [
            for (int index = 0; index < widget.question.options.length; index++)
              getListTile(index, widget.question.options[index],
                  widget.question.qid, state),
            SizedBox(
              height: 10,
            ),
            state.hasError
                ? Text(state.errorText ?? "",
                    style: TextStyle(color: Colors.red[400]))
                : SizedBox(),
          ],
        );
      },
      validator: (bool? value) {
        if (widget.question.isRequired && (value == null || !value)) {
          return "Field is Required !!";
        }else
          return null;
      },
    );
  }

  Widget getListTile(i, option, qid, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<int?>(
          value: i,
          groupValue: selected,
          onChanged: (int? value) {
            widget.onChangedListener(value);
            state.setValue(true);
            setState(() {
              selected = value;
            });
          },
        ),
        SizedBox(
          width: 0,
        ),
        Text(option),
      ],
    );
  }
}
