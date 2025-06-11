import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';

class Filter extends StatelessWidget {
  final String filterName;
  final bool isActivated;
  final onTap;
  const Filter({Key? key, required this.filterName, required this.isActivated, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        margin: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          color: isActivated ? Colors.teal : cPrimary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(filterName, style: TextStyle(color: cWhite),),
      ),
    );
  }
}

