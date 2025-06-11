import 'package:flutter/material.dart';
import 'package:surveyapp/helpers/colors.dart';

class CannotTakeImageDialog extends StatefulWidget {
  final cannotTake;
  final String? defaultReason;
  const CannotTakeImageDialog({Key? key, required this.cannotTake, required this.defaultReason}) : super(key: key);

  @override
  _CannotTakeImageDialogState createState() => _CannotTakeImageDialogState();
}

class _CannotTakeImageDialogState extends State<CannotTakeImageDialog> {

  List<String> reasons = ['Network Problem', 'Photo Not Allowed', 'Videos Not Allowed', 'Technical Error '];
  int selected = -1;

  @override
  void initState() {
    this.selected = reasons.indexOf(widget.defaultReason == null ? "": widget.defaultReason!, 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reason for not Taking Image'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children:
        reasons.map<Widget>((reason){
          return InkWell(
            onTap: (){
              setState((){
                selected = reasons.indexOf(reason, 0);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (selected == reasons.indexOf(reason, 0) ? Colors.amber : cPrimary)
              ),
              child: Text(reason, style: TextStyle(color: cWhite, fontSize: 12)),
            ),
          );
        }).toList(),
      ),
      actions: [
        ElevatedButton(
          child: Text('Submit', style: TextStyle(color: cWhite)),
          onPressed: () {
            widget.cannotTake(reason: selected == -1 ? null : reasons[selected]);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: cSecondary,
              backgroundColor: cSecondary,
              elevation: 3),
        ),
        ElevatedButton(
          child: Text('Clear', style: TextStyle(color: cWhite)),
          onPressed: () {
            setState((){
              selected =-1;
            });
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: cPrimary,
              backgroundColor: cPrimary,
              elevation: 3),
        ),
        ElevatedButton(
          child: Text('Close', style: TextStyle(color: cWhite)),
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              foregroundColor: cPrimary,
              backgroundColor: cPrimary,
              elevation: 3),
        ),
      ],
    );
  }
}
