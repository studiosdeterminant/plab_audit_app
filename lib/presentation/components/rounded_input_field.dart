import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';

import 'text_field_container.dart';

class RoundedInputField extends StatelessWidget {

  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final inputValidator;

  const RoundedInputField(
      {
        Key? key,
        required this.hintText,
        required this.onChanged,
        this.inputValidator,
        this.icon = Icons.person,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: cWhite,
        style: TextStyle(color: cWhite),
        validator: inputValidator,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: cWhite,
          ),
          hintText: hintText,
          border: InputBorder.none
        ),
      )
    );
  }
}
