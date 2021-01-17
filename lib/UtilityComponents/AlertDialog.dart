import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String message,
    List<Function> functions, List<String> buttonTexts) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text(
      "Dismiss",
      style: TextStyle(fontSize: 16),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: (Iterable<int>.generate(functions.length).toList())
        .map((index) => FlatButton(
              child: Text(
                buttonTexts[index],
                style: TextStyle(fontSize: 16),
              ),
              onPressed: functions[index],
            ))
        .toList(),
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
