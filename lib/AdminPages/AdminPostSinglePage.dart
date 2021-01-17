import 'dart:async';

import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/UtilityComponents/AlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ColorConstants.dart' as colourconstants;
import 'package:timeago/timeago.dart' as timeago;

class AdminPostSinglePage extends StatefulWidget {
  AdminPostSinglePage({Key key, this.postId, this.postTitle}) : super(key: key);
  @override
  _AdminPostSinglePageState createState() => _AdminPostSinglePageState();

  String postId;
  String postTitle;
}

class _AdminPostSinglePageState extends State<AdminPostSinglePage> {
  final answerTextController = TextEditingController();
  var focusNode = new FocusNode();
  bool upvoteProcessing = false;
  bool isEditExistingAnswer = false;
  String editingAnswerDocumentId = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    answerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          children: [
            _postTopQuestionBar(),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("comments")
                    .where("post_id", isEqualTo: widget.postId)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.data.documents.length == 0)
                    return Center(
                      child: Text("No answers yet. Help your friend out!"),
                    );
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(snapshot.data.documents[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Column(
          children: [Spacer(), _answerTextFieldComponent()],
        )
      ],
    ));
  }

  Widget _answerTextFieldComponent() {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              (isEditExistingAnswer
                  ? Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        child: Icon(Icons.cancel, color: Colors.red),
                        onTap: () => _handleCancelEditingAnswerClick(),
                      ),
                    )
                  : Container()),
              Flexible(
                child: TextField(
                  style: TextStyle(fontSize: 14),
                  focusNode: focusNode,
                  controller: answerTextController,
                  decoration: new InputDecoration(
                      enabledBorder: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0.0),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(35.0),
                        ),
                      ),
                      border: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0.0),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(35.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(
                          color: Colors.grey[600], fontWeight: FontWeight.bold),
                      hintText: "Reply to the question",
                      fillColor: Colors.black12),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              GestureDetector(
                child: Icon(Icons.send),
                onTap: () => _handleSendReplyButton(),
              )
            ],
          ),
        ));
  }

  Widget _postTopQuestionBar() {
    return Container(
      color: colourconstants.topBarColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Spacer(),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    bool isBookmarked = false;
                    if (snapshot.data.data()["bookmarks"] != null) {
                      if (snapshot.data
                          .data()["bookmarks"]
                          .contains(widget.postId)) {
                        isBookmarked = true;
                      }
                    }
                    return GestureDetector(
                      onTap: () => _handleBookmarkTapped(!isBookmarked),
                      child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? Colors.transparent
                              : Colors.transparent),
                    );
                  },
                ),
                SizedBox(
                  width: 12,
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.postTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_drop_up,
                        size: 50,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(0),
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .doc(widget.postId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Text("");
                        return Text(
                          snapshot.data.data()["upvotes_count"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(DocumentSnapshot document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _listItemLeftComponent(document),
              SizedBox(
                width: 16,
              ),
              Flexible(
                child: _listItemRightComponent(document),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black26,
          height: 0.5,
        )
      ],
    );
  }

  Widget _listItemLeftComponent(DocumentSnapshot document) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: () => _upvoteClickHandler(document),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("comments_upvotes")
                  .where('user_id',
                      isEqualTo: FirebaseAuth.instance.currentUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                bool hasUpvoted = snapshot.data.documents
                    .map((e) => e.data()["comment_id"])
                    .contains(document.id);
                return Icon(Icons.arrow_drop_up,
                    size: 35,
                    color: hasUpvoted
                        ? colourconstants.buttonGreen
                        : Colors.black12);
              },
            )),
        Text(
          document.data()["upvotes_count"].toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  //   stream: FirebaseFirestore.instance
  //     .collection("posts_upvotes")
  //     .where('user_id',
  //         isEqualTo: FirebaseAuth.instance.currentUser.email)
  //     .snapshots(),
  // builder: (context, snapshot) {
  //   if (!snapshot.hasData) return Container();
  //   var currentUserEmail = FirebaseAuth.instance.currentUser.email;
  // bool hasUpvoted = snapshot.data.documents
  //     .map((e) => e.data()["post_id"])
  //     .contains(document.id);

  Widget _listItemRightComponent(DocumentSnapshot document) {
    Timestamp answerDateTime = document.data()["created_at"];

    TextStyle contentStyle =
        TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    TextStyle infoStyle = TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    document.data()["content"],
                    style: contentStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(document.data()["user_id"])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox.shrink();
                      return Text(
                        (false
                                ? "Anonymous"
                                : snapshot.data.data()["full_name"]) +
                            " • " +
                            (answerDateTime == null
                                ? " "
                                : timeago.format(answerDateTime.toDate())),
                        style: infoStyle,
                      );
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                width: 20,
                child: GestureDetector(
                  child: Icon(
                    Icons.check,
                    color: document.data()["marked_correct"]
                        ? Colors.green
                        : Colors.black12,
                    size: 30,
                  ),
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection("comments")
                        .doc(document.id)
                        .update({
                      "marked_correct": !document.data()["marked_correct"]
                    });
                  },
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 6,
        ),
        document.data()["user_id"] ==
                FirebaseAuth.instance.currentUser
                    .email //only allow edit option for own post
            ? Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    child: Icon(Icons.edit),
                    onTap: () => _handleEditAnswerClicked(
                        document.id, document.data()["content"]),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    child: Icon(Icons.delete),
                    onTap: () => _handleDeleteClicked(document.id),
                  )
                ],
              )
            : Container()
      ],
    );
  }

  void _upvoteClickHandler(DocumentSnapshot document) {
    if (upvoteProcessing) return;
    upvoteProcessing = true;
    Timer(Duration(seconds: 1), () {
      //this timer is to prevent spamming the upvote button and mess up the value
      upvoteProcessing = false;
    });
    var replyUpvoteRef = FirebaseFirestore.instance
        .collection('comments_upvotes')
        .where("comment_id", isEqualTo: document.id)
        .get()
        .then((value) {
      if (value.docs
              .map((e) => e.data()["user_id"])
              .contains(FirebaseAuth.instance.currentUser.email) ==
          false) {
        FirebaseFirestore.instance
            .collection("comments")
            .doc(document.id)
            .update({'upvotes_count': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection("comments_upvotes").add({
          'user_id': FirebaseAuth.instance.currentUser.email,
          'comment_id': document.id
        });
      } else {
        FirebaseFirestore.instance
            .collection("comments")
            .doc(document.id)
            .update({'upvotes_count': FieldValue.increment(-1)});

        FirebaseFirestore.instance
            .collection("comments_upvotes")
            .doc(value.docs[0].id)
            .delete();
      }
    });
  }

  void _handleSendReplyButton() {
    if (isEditExistingAnswer) {
      FirebaseFirestore.instance
          .collection("comments")
          .doc(editingAnswerDocumentId)
          .update({'content': answerTextController.text});

      answerTextController.clear();
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } else {
      FirebaseFirestore.instance.collection("comments").add({
        'content': answerTextController.text,
        'created_at': FieldValue.serverTimestamp(),
        'post_id': widget.postId,
        'upvotes_count': 0,
        'marked_correct': false,
        'user_id': FirebaseAuth.instance.currentUser.email
      });
      //the code below to dismiss the keyboard
      answerTextController.clear();
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    isEditExistingAnswer = false;
  }

  void _handleDeleteClicked(String documentid) {
    Function yesHandler = () {
      FirebaseFirestore.instance
          .collection("comments")
          .doc(documentid)
          .delete();
      Navigator.of(context).pop();
    };
    Function noHandler = () => Navigator.of(context).pop();
    showAlertDialog(
        context,
        "Delete Answer",
        "Are you sure you want to delete the answer?",
        [noHandler, yesHandler],
        ["No", "Yes"]);
  }

  void _handleEditAnswerClicked(String documentid, String content) {
    isEditExistingAnswer = true;
    editingAnswerDocumentId = documentid;
    answerTextController.text = content;
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _handleCancelEditingAnswerClick() {
    answerTextController.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    isEditExistingAnswer = false;
  }

  void _handleBookmarkTapped(bool isCreatingBookmark) {
    if (isCreatingBookmark) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        'bookmarks': FieldValue.arrayUnion([widget.postId])
      });
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        'bookmarks': FieldValue.arrayRemove([widget.postId])
      });
    }
  }
}
