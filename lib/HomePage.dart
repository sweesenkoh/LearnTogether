import 'package:LearnTogether/ColorConstants.dart';
import 'package:LearnTogether/ForumSinglePage.dart';
import 'package:LearnTogether/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;
import 'UtilityComponents/NavigationBar.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<QuerySnapshot> enrolledForumsSnapshot = FirebaseFirestore.instance
      .collection("user_enrolled_forums")
      .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser.email)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colourconstants.backgroundColor,
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  color: colourconstants.backgroundColor,
                ),
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    height: 120,
                    decoration:
                        BoxDecoration(color: colourconstants.topBarColor),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Icon(Icons.search, color: Colors.transparent),
                          ),
                          Text("Forums",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 45,
                                  color: Colors.white)),
                          GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(
                                Icons.search,
                                color: Colors.transparent,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          Text("Search Page")));
                            },
                          )
                        ],
                      )),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: StreamBuilder(
              //first stream builder is to get the ids of forums that this user is enrolled to
              stream: enrolledForumsSnapshot,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("forums")
                      .where(FieldPath.documentId,
                          whereIn: snapshot.data.documents
                              .map((x) => x.data()["forum_id"])
                              .toList()) //we query only forums where the id is inside the forums enrolled by this user
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    return Container(
                      color: colourconstants.backgroundColor,
                      child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) => _buildListItem(
                              context, snapshot.data.documents[index])),
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
}
