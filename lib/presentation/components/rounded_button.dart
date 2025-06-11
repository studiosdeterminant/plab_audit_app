import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';

class RoundedButton extends StatelessWidget {
  final press;
  final Widget child;
  final Color color;

  const RoundedButton({
    Key? key,
    required this.child,
    required this.press,
    this.color = cPrimary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: Size(88, 44),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
    );

    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: flatButtonStyle,
          onPressed: press,
          child: child,
        ),
      ),
    );
  }
}
