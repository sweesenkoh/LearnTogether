import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/CreatePost.dart';
import 'package:LearnTogether/PostSinglePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;

class CreatePost extends StatefulWidget {
  CreatePost({Key key, this.forumId, this.forumTitle, this.userId})
      : super(key: key);
  @override
  _CreatePostState createState() => _CreatePostState();

  String userId;
  String forumId;
  String forumTitle;
}

class _CreatePostState extends State<CreatePost> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Create Post"),
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
                  hintText: "Type your question here",
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
                      "Create",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14),
                    ),
                    onPressed: () async {
                      setState(() {
                        getValue = contentController.text;
                      });

                      if (getValue.isNotEmpty) {
                        FirebaseFirestore.instance.collection("posts").add({
                          "content": getValue,
                          "forum_id": widget.forumId,
                          "upvotes_count": 0,
                          "reported_count": 0,
                          "user_id": FirebaseAuth.instance.currentUser.email,
                          "created_at": FieldValue.serverTimestamp()
                        });

                        Navigator.pop(context);
                      }
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
