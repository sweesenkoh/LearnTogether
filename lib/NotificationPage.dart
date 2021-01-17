import 'dart:async';

import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/CreatePost.dart';
import 'package:LearnTogether/PostSinglePage.dart';
import 'package:LearnTogether/UtilityComponents/NavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;
import 'package:LearnTogether/HomePage.dart';
import 'EditPost.dart';
import 'UtilityComponents/ConfirmDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colourconstants.backgroundColor,
        body: Column(
          children: [
            NavigationBar("Notifications"),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("notifications")
                    .where("user_id",
                        isEqualTo: FirebaseAuth.instance.currentUser.email)
                    .orderBy("created_at", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  return ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) =>
                        _buildListItem(context, snapshot.data.documents[index]),
                  );
                },
              ),
            )
          ],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .doc(document.data()["post_id"])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data.data() == null)
          return Container();
        return Padding(
          padding: EdgeInsets.all(0),
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PostSinglePage(
                      postId: document.data()["post_id"],
                      postTitle: snapshot.data.data()["content"],
                    ),
                  ));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Flexible(
                            child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(document.data()["reply_user_id"])
                              .snapshots(),
                          builder: (context, snapshot2) {
                            if (!snapshot2.hasData) return Container();
                            return Text(
                              (snapshot2.data.data()["hide_name"]
                                      ? "An Anonymous"
                                      : snapshot2.data.data()["full_name"]) +
                                  " has answered your following post: " +
                                  snapshot.data.data()["content"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            );
                          },
                        )),
                        SizedBox(
                          width: 16,
                        ),
                        Icon(Icons.arrow_forward_ios)
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(timeago
                          .format(document.data()["created_at"].toDate()))
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 0.5,
                  color: Colors.black26,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
