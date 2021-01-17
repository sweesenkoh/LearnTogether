import 'dart:async';

import 'package:LearnTogether/AdminPages/AdminPostSinglePage.dart';
import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/CreatePost.dart';
import 'package:LearnTogether/PostSinglePage.dart';
import 'package:LearnTogether/UtilityComponents/AlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ColorConstants.dart' as colourconstants;

import '../EditPost.dart';
import '../UtilityComponents/ConfirmDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminForumSinglePage extends StatefulWidget {
  AdminForumSinglePage({Key key, this.forumId, this.forumTitle})
      : super(key: key);
  @override
  _AdminForumSinglePageState createState() => _AdminForumSinglePageState();

  String forumId;
  String forumTitle;
}

class _AdminForumSinglePageState extends State<AdminForumSinglePage> {
  bool confirm = false;
  Stream firestorePostsStream;
  bool upvoteProcessing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firestorePostsStream = FirebaseFirestore.instance
        .collection("posts")
        .where("forum_id", isEqualTo: widget.forumId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
          length: 4,
          child: Scaffold(
              body: Column(
            children: [
              _forumTopInfoBar(),
              Container(
                color: colourconstants.topBarColor,
                child: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.text_fields),
                      text: "Posts",
                    ),
                    Tab(
                      icon: Icon(Icons.report_problem),
                      text: "Reported",
                    ),
                    Tab(
                      icon: Icon(Icons.group),
                      text: "Statistics",
                    ),
                    Tab(
                      icon: Icon(Icons.info),
                      text: "Info",
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                children: [
                  _postsListView(),
                  _reportedPostsListView(),
                  _tableStatistic(),
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("forums")
                          .doc(widget.forumId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      'https://news.nus.edu.sg/system/files/webform/staff_awards/487/Prof-Linga-photo.jpg')),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(snapshot.data.data()["creator_id"])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();
                                return Text(
                                  snapshot.data.data()["full_name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                );
                              },
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              snapshot.data.data()["course_info"],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w300),
                            )
                          ],
                        );
                      },
                    ),
                  )
                ],
              ))
            ],
          ))),
    );
  }

  Widget _tableStatistic() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("user_enrolled_forums")
          .where("forum_id", isEqualTo: widget.forumId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(),
          );
        return Padding(
          padding: EdgeInsets.all(22),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            border: TableBorder.all(width: 1, color: Colors.black38),
            children: [
                  TableRow(
                      children: [
                    "Name",
                    "Post Count",
                    "Answer Count",
                    "Correct Answer Count"
                  ]
                          .map((e) => TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    e,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ))
                          .toList()),
                ] +
                List<TableRow>.from(snapshot.data.documents
                    .map((x) => TableRow(
                          children: [
                            _tableUserName(x.data()["user_id"]),
                            _postCountCounter(x.data()["user_id"]),
                            _answerCountCounter(x.data()["user_id"], false),
                            _answerCountCounter(x.data()["user_id"], true),
                          ],
                        ))
                    .toList()),
          ),
        );
      },
    );
  }

  Widget _tableUserName(String user_id) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user_id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null)
          return TableCell(
            child: Container(
              child: Text("wtf"),
            ),
          );
        Future.delayed(const Duration(milliseconds: 200), () {
// Here you can write your code
          this.setState(() {});
        });
        return TableCell(
          child: Padding(
              padding: EdgeInsets.all(6),
              child: Text(snapshot.data.data()["full_name"])),
        );
      },
    );
  }

  Widget _postCountCounter(String user_id) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where("forum_id", isEqualTo: widget.forumId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return TableCell(
            child: Padding(
                padding: EdgeInsets.all(6),
                child: Text("0", textAlign: TextAlign.center)),
          );
        var mydata = snapshot.data.documents
            .where((x) => x.data()["user_id"] == user_id)
            .toList();
        if (mydata == null)
          return TableCell(
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Text(
                "0",
                textAlign: TextAlign.center,
              ),
            ),
          );
        return TableCell(
          child: Padding(
              padding: EdgeInsets.all(6),
              child:
                  Text(mydata.length.toString(), textAlign: TextAlign.center)),
        );
      },
    );
  }

  Widget _answerCountCounter(String user_id, bool enforceCorrect) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where("forum_id", isEqualTo: widget.forumId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null)
          return TableCell(
            child: Padding(
                padding: EdgeInsets.all(6),
                child: Text("0", textAlign: TextAlign.center)),
          );
        //for each post that belong to this forum, i want to find the answers, and filter by the name
        var postArray =
            snapshot.data.documents.map((x) => x.id.toString()).toList();

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("comments")
              .where("post_id", whereIn: postArray)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return TableCell(
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    "0",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            var mylist = snapshot.data.documents
                .where((x) =>
                    x.data()["user_id"] == user_id &&
                    (enforceCorrect ? x.data()["marked_correct"] : true))
                .toList();

            var mycount = mylist.length;
            return TableCell(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  mycount.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }

  //, _postsListView()

  int _value = 0;
  List<String> _value_representations = ["created_at", "upvotes_count"];

  Widget _postsListView() {
    return Scaffold(
      backgroundColor: colourconstants.backgroundColor,
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () => _addButtonClickHandler(),
      //     child: Icon(Icons.add_comment),
      //     backgroundColor: colourconstants.buttonGreen),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .where("forum_id", isEqualTo: widget.forumId)
            .orderBy(_value_representations[_value], descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data.documents.length == 0)
            return Center(
              child: Text("No posts yet. Create a post now!"),
            );
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Spacer(),
                    Icon(Icons.sort),
                    SizedBox(
                      width: 6,
                    ),
                    DropdownButton(
                        value: _value,
                        items: [
                          DropdownMenuItem(
                            child: Text("Chronological"),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text("Upvotes"),
                            value: 1,
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                          });
                        })
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return _buildPostListItem(snapshot.data.documents[index]);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _reportedPostsListView() {
    return Scaffold(
      backgroundColor: colourconstants.backgroundColor,
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () => _addButtonClickHandler(),
      //     child: Icon(Icons.add_comment),
      //     backgroundColor: colourconstants.buttonGreen),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .where("forum_id", isEqualTo: widget.forumId)
            .orderBy('reported_count', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data.documents.length == 0)
            return Center(
              child: Text("No posts yet. Create a post now!"),
            );
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 80),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              if (snapshot.data.documents[index].data()["reported_count"] == 0)
                return Container();
              return _buildPostListItem(snapshot.data.documents[index]);
            },
          );
        },
      ),
    );
  }

  Widget _forumTopInfoBar() {
    return Container(
      color: colourconstants.topBarColor,
      height: 110,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 25,
                ),
                Flexible(
                  child: Text(
                    widget.forumTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
            // SizedBox(
            //   height: 24,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     StreamBuilder(
            //       stream: firestorePostsStream,
            //       builder: (context, snapshot) {
            //         if (!snapshot.hasData) return Container();
            //         return _topInfoBarNumberComponent(
            //             snapshot.data.documents.length.toString(), "posts");
            //       },
            //     ),
            //     _topInfoBarNumberComponent("10", "upvotes"),
            //     _topInfoBarNumberComponent("219", "students"),
            //     GestureDetector(
            //       child: Icon(
            //         Icons.sort,
            //         color: Colors.white,
            //       ),
            //       onTap: () {
            //         print("Clicking");
            //       },
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  Widget _topInfoBarNumberComponent(String number, String name) {
    TextStyle numberStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
    TextStyle nameStyle = TextStyle(color: Colors.white70, fontSize: 14);
    return Row(
      children: [
        Text(
          number,
          style: numberStyle,
        ),
        SizedBox(
          width: 3,
        ),
        Text(
          name,
          style: nameStyle,
        )
      ],
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
          onLongPress: () => showAlertDialog(context, "Report Post",
              "Are you sure you want to report this post?", [
            () {
              Navigator.pop(context);
            },
            () {
              FirebaseFirestore.instance
                  .collection("posts")
                  .doc(document.id)
                  .update({'reported_count': FieldValue.increment(1)});
              Navigator.pop(context);
              _showReportedToast(context);
            }
          ], [
            "Cancel",
            "Yes"
          ]),
          onTap: () => _postCellClickHandler(document),
          child: Padding(
              padding: EdgeInsets.all(16),
              child: _postCellCardInnerContent(document)),
        ),
      ),
    );
  }

  void _showReportedToast(BuildContext context) {
    showAlertDialog(
        context, "Success", "You have successfully reported the posts!", [
      () {
        Navigator.pop(context);
      },
    ], [
      "Dismiss"
    ]);
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
                    return Text((false
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
            SizedBox(height: 16.0),
            Text(
              "Reported Count: " + document.data()['reported_count'].toString(),
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.deepOrange),
            ),
            SizedBox(height: 16.0),
            if (true) //only allow user to edit their own post
              Row(
                mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Spacer(),
                  // GestureDetector(
                  //   onTap: () => _editPostClickHandler(document),
                  //   child: Icon(Icons.edit),
                  // ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  GestureDetector(
                    onTap: () => _deletePostClickHandler(document),
                    child: Icon(Icons.delete),
                  ),
                  // FlatButton.icon(
                  //   onPressed: () => _editPostClickHandler(document),
                  //   icon: Icon(Icons.edit),
                  //   label: Text(""),
                  //   color: Colors.white,
                  // ),
                  // FlatButton.icon(
                  //   onPressed: () => _deletePostClickHandler(document),
                  //   icon: Icon(Icons.delete),
                  //   label: Text(""),
                  //   // label: Text('Delete'),
                  //   color: Colors.white,
                  // )
                ],
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
            builder: (context) => AdminPostSinglePage(
                postId: document.id, postTitle: document.data()["content"])));
  }

  void _addButtonClickHandler() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePost(
                  userId: FirebaseAuth.instance.currentUser.email,
                  forumId: widget.forumId,
                  forumTitle: widget.forumTitle,
                )));
  }

  void _editPostClickHandler(DocumentSnapshot document) {
    Future.delayed(Duration(seconds: 4));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPost(
                  userId: FirebaseAuth.instance.currentUser.email,
                  forumId: widget.forumId,
                  forumTitle: widget.forumTitle,
                  postId: document.id,
                  postTitle: document.data()["content"],
                  fullName: "",
                )));
  }

  void _deletePostClickHandler(DocumentSnapshot document) async {
    confirm = await showConfirmDialog(
        context, document.data()["content"], document.id, "delete");
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
