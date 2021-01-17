import 'package:LearnTogether/ColorConstants.dart';
import 'package:LearnTogether/ForumSinglePage.dart';
import 'package:LearnTogether/HomePage.dart';
import 'package:LearnTogether/LoginPage.dart';
import 'package:LearnTogether/UtilityComponents/NavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;

class ProfilePage extends StatefulWidget {
  ProfilePage({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isHideName = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        NavigationBar("Profile"),
        profileContainer(),
        Expanded(
          child: Container(
            color: colourconstants.backgroundColor,
          ),
        )
      ],
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget profileContainer() {
    return Container(
        color: colourconstants.backgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());
                      return Column(
                        children: [
                          rowGenerator(
                              "Name", snapshot.data.data()["full_name"]),
                          rowDivider(),
                          rowGenerator("Major", snapshot.data.data()["major"]),
                          rowDivider(),
                          rowGenerator(
                              "Year", snapshot.data.data()["year"].toString()),
                          rowDivider(),
                          rowGenerator(
                              "School", snapshot.data.data()["school"]),
                          rowDivider(),
                          rowGenerator(
                              "Account", snapshot.data.data()["account_type"]),
                          rowDivider(),
                          rowGenerator("Hide Name", "", true,
                              snapshot.data.data()["hide_name"]),
                          rowDivider(),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.transparent)),
                            color: Colors.red,
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14),
                            ),
                            onPressed: () {
                              FirebaseMessaging().getToken().then(
                                  (tokenValue) => FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth
                                              .instance.currentUser.email)
                                          .update({
                                        'fcm_tokens':
                                            FieldValue.arrayRemove([tokenValue])
                                      }));

                              FirebaseAuth.instance.signOut();
                            },
                          )
                        ],
                      );
                    },
                  )),
            ),
          ),
        ));
  }

  Widget rowDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Container(
        height: 0.5,
        color: Colors.black38,
      ),
    );
  }

  Widget rowGenerator(String leftLabel, String rightLabel,
      [bool isHideNameSwitch = false, bool hideNameValue = false]) {
    TextStyle textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    return Row(
      children: [
        Text(
          leftLabel,
          style: textStyle,
        ),
        Spacer(),
        !isHideNameSwitch
            ? Text(
                rightLabel,
                style: textStyle,
              )
            : Container(
                height: 20,
                child: Switch(
                  value: hideNameValue,
                  onChanged: (value) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser.email)
                        .update({'hide_name': value});
                  },
                  activeTrackColor: colourconstants.toggleTrackColor,
                  activeColor: colourconstants.toggleColor,
                ),
              ),
      ],
    );
  }
}
