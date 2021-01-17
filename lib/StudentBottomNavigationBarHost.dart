import 'package:LearnTogether/BookmarksPage.dart';
import 'package:LearnTogether/HomePage.dart';
import 'package:LearnTogether/NotificationPage.dart';
import 'package:LearnTogether/ProfilePage.dart';
import 'package:LearnTogether/UtilityComponents/AlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colorconstants;

class StudentBottomNavigationBarHost extends StatefulWidget {
  StudentBottomNavigationBarHost({Key key}) : super(key: key);

  @override
  _StudentBottomNavigationBarHostState createState() =>
      _StudentBottomNavigationBarHostState();
}

class _StudentBottomNavigationBarHostState
    extends State<StudentBottomNavigationBarHost> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //setting up logic for push notification
    _fcm.getToken().then((tokenValue) {
      _db.collection("users").doc(_auth.currentUser.email).update({
        'fcm_tokens': FieldValue.arrayUnion([tokenValue])
      });
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        showAlertDialog(
            context,
            message["notification"]["title"],
            message["notification"]["body"],
            [() => Navigator.of(context).pop()],
            ["Dismiss"]);
      },

      //in future need to setup others to handle notification when app is in background
    );
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    NotificationPage(),
    BookmarksPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        animationDuration: Duration(milliseconds: 250),
        backgroundColor: colorconstants.backgroundColor,
        items: [
          Icon(Icons.home),
          Icon(Icons.notifications),
          Icon(Icons.bookmark),
          Icon(Icons.account_box)
        ],
        // items: const <BottomNavigationBarItem>[
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.home),
        //     title: Text('Home'),
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.account_box),
        //     title: Text('Account'),
        //   ),
        // ],
        // currentIndex: _selectedIndex,
        // selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
