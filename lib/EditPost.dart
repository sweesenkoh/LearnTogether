import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/CreatePost.dart';
import 'package:LearnTogether/PostSinglePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;
import 'UtilityComponents/ConfirmDialog.dart';

class EditPost extends StatefulWidget {
  EditPost(
      {Key key,
      this.postId,
      this.postTitle,
      this.userId,
      this.forumTitle,
      this.forumId,
      this.fullName})
      : super(key: key);
  @override
  _EditPostState createState() => _EditPostState();
  String userId;
  String postId;
  String postTitle;
  String forumId;
  String forumTitle;
  String fullName;
}

class _EditPostState extends State<EditPost> {
  String getValue;
  bool confirm = false;
  TextEditingController contentController = new TextEditingController(text: "");

  @override
  void dispose() {
    // TODO: implement dispose
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    contentController.value =
        contentController.value.copyWith(text: widget.postTitle);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Edit Post"),
        backgroundColor: colourconstants.topBarColor,
      ),
      body: Column(children: [inputFields()]),
    );
  }

  Widget inputFields() {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.forumTitle}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text("Body ", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLength: 200,
              keyboardType: TextInputType.text,
              maxLines: 12,
              decoration: new InputDecoration(
                  enabledBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(12.0),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white70),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return Column(
                  children: [
                    Text("Author: ${snapshot.data.data()["full_name"]} ",
                        style: TextStyle(fontSize: 15)),
                    Text("Name Hidden: ${snapshot.data.data()["hide_name"]} ",
                        style: TextStyle(fontSize: 15))
                  ],
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.transparent)),
                  color: colourconstants.topBarColor,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.transparent)),
                  color: colourconstants.topBarColor,
                  child: Text(
                    "Confirm",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14),
                  ),
                  onPressed: () async {
                    setState(() {
                      getValue = contentController.text;
                    });

                    confirm = await showConfirmDialog(
                        context, getValue, widget.postId, "edit");
                    //FirebaseFirestore.instance.collection("posts").doc(widget.postId).update({"content":getValue});
                    if (confirm == true) Navigator.pop(context);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
