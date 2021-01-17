import 'dart:async';

import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/CreatePost.dart';
import 'package:LearnTogether/PostSinglePage.dart';
import 'package:LearnTogether/ForumSinglePage.dart';
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

class BookmarksPage extends StatefulWidget {
  BookmarksPage({Key key}) : super(key: key);
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  // List<User> users;
  // Stream<QuerySnapshot> bookmarksSnapshot = FirebaseFirestore.instance
  //     .collection("users")
  //     .where(FieldPath.documentId, isEqualTo: FirebaseAuth.instance.currentUser.email)
  //     .snapshots();

  bool upvoteProcessing = false;

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
            NavigationBar("Bookmarks"),
            Expanded(
                child: StreamBuilder(
              //first stream builder is to get the ids of forums that this user is enrolled to
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.data.data()["bookmarks"] == null ||
                    snapshot.data.data()["bookmarks"].length == 0)
                  return Center(
                    child: Text(
                        "No bookmarks. Go ahead and bookmark some posts now!"),
                  );
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .where(FieldPath.documentId,
                          whereIn: snapshot.data.data()[
                              "bookmarks"]) //we query only forums where the id is inside the forums enrolled by this user
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    return Container(
                      color: colourconstants.backgroundColor,
                      child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return _buildPostListItem(
                              snapshot.data.documents[index]);
                        },
                      ),
                    );
                  },
                );
              },
            )),
          ],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ForumSinglePage(
                        forumId: document.id,
                        forumTitle: document.data()["title"])));
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.data()["title"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      document.data()["description"],
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostListItem(DocumentSnapshot document) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.blue.withAlpha(30),
          onTap: () => _postCellClickHandler(document),
          child: Padding(
              padding: EdgeInsets.all(16),
              child: _postCellCardInnerContent(document)),
        ),
      ),
    );
  }

  Widget _postCellCardInnerContent(DocumentSnapshot document) {
    String postTitle = document.data()["content"];
    String upvoteCount = document.data()["upvotes_count"].toString();

    if (document.data()["created_at"] == null) {
      return Container(); //when the post first created, the created_at field is momentarily null, so need check
    }

    DateTime postDateTime = document.data()["created_at"].toDate();
    List<String> postTimeStamp = document
        .data()["created_at"]
        .toDate()
        .toString()
        .replaceAll("-", "/")
        .split(":");

    postTimeStamp.removeLast();
    String postTimeStampFormatted = postTimeStamp.join(":");

    TextStyle postTitleStyle =
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

    Widget leftUpvoteComponent = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 40,
          width: 45,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("posts_upvotes")
                .where('user_id',
                    isEqualTo: FirebaseAuth.instance.currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              var currentUserEmail = FirebaseAuth.instance.currentUser.email;
              bool hasUpvoted = snapshot.data.documents
                  .map((e) => e.data()["post_id"])
                  .contains(document.id);
              return IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.arrow_drop_up,
                    size: 45,
                    color: hasUpvoted
                        ? colourconstants.buttonGreen
                        : Colors.black26,
                  ),
                  onPressed: () => _upvoteClickHandler(document));
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 12),
          child: Text(
            upvoteCount,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Text(""),
      ],
    );

    return Row(
      children: [
        leftUpvoteComponent,
        SizedBox(
          width: 18,
        ),
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              postTitle,
              style: postTitleStyle,
            ),
            SizedBox(height: 15.0),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(document.data()["user_id"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text("Loading...");
                var hideName = snapshot.data.data()["hide_name"];
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("comments")
                      .where('post_id', isEqualTo: document.id)
                      .snapshots(),
                  builder: (context2, snapshot2) {
                    if (!snapshot2.hasData) return Text("Loading...");
                    return Text((hideName
                            ? "Anonymous"
                            : snapshot.data.data()["full_name"]) +
                        " • " +
                        timeago.format(postDateTime) +
                        " • " +
                        snapshot2.data.documents.length.toString() +
                        " answers");
                  },
                );
                // return Text((hideName
                //         ? "Anonymous"
                //         : snapshot.data.data()["full_name"]) +
                //     " • " +
                //     timeago.format(postDateTime) + " • " +);
              },
            ),
          ],
        ))
      ],
    );
  }

  void _postCellClickHandler(DocumentSnapshot document) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => PostSinglePage(
                postId: document.id, postTitle: document.data()["content"])));
  }

  void _upvoteClickHandler(DocumentSnapshot document) {
    if (upvoteProcessing) return;
    upvoteProcessing = true;
    Timer(Duration(seconds: 1), () {
      //this timer is to prevent spamming the upvote button and mess up the value
      upvoteProcessing = false;
    });
    var postUpvoteRef = FirebaseFirestore.instance
        .collection('posts_upvotes')
        .where("post_id", isEqualTo: document.id)
        .get()
        .then((value) {
      if (value.docs
              .map((e) => e.data()["user_id"])
              .contains(FirebaseAuth.instance.currentUser.email) ==
          false) {
        FirebaseFirestore.instance
            .collection("posts")
            .doc(document.id)
            .update({'upvotes_count': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection("posts_upvotes").add({
          'user_id': FirebaseAuth.instance.currentUser.email,
          'post_id': document.id
        });
      } else {
        FirebaseFirestore.instance
            .collection("posts")
            .doc(document.id)
            .update({'upvotes_count': FieldValue.increment(-1)});

        FirebaseFirestore.instance
            .collection("posts_upvotes")
            .doc(value.docs[0].id)
            .delete();
      }
    });
  }
}
