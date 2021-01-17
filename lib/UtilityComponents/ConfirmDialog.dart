import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ColorConstants.dart' as colourconstants;

Future<bool> showConfirmDialog(
    BuildContext context, String title, String postId, String confirmType) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to $confirmType?'),
          content: Text(
            '$title',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            Spacer(),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.transparent)),
              color: colourconstants.topBarColor,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            // SizedBox(
            //   width: 132,
            // ),
            Spacer(),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.transparent)),
              color: Colors.red,
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                if (confirmType == "edit")
                  FirebaseFirestore.instance
                      .collection("posts")
                      .doc(postId)
                      .update({"content": title});
                else
                  FirebaseFirestore.instance
                      .collection("posts")
                      .doc(postId)
                      .delete();
                Navigator.pop(context, true);
              },
            ),
            Spacer(),
          ],
        );
      });
}
