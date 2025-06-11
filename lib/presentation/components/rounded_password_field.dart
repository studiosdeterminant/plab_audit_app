import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/presentation/components/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final inputValidator;

  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
    this.inputValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        validator: inputValidator,
        onChanged: onChanged,
        cursorColor: cWhite,
        style: TextStyle(color: cWhite),
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: cWhite,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
