import 'package:LearnTogether/AdminPages/AdminBottomNavigationBarHost.dart';
import 'package:LearnTogether/ColorConstants.dart';
import 'package:LearnTogether/StudentBottomNavigationBarHost.dart';
import 'package:LearnTogether/HomePage.dart';
import 'package:LearnTogether/LoginPage.dart';
//import 'package:LearnTogether/Services/PushNotificationManager.dart';
import 'package:LearnTogether/UtilityComponents/AlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoginPage();
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              if (snapshot.data.data()["account_type"] == "student") {
                topBarColor = topBarColorStudent;
                return StudentBottomNavigationBarHost();
              }

              if (snapshot.data.data()["account_type"] == "coordinator") {
                topBarColor = topBarColorAdmin;
                return AdminBottomNavigationBarHost();
              }
            },
          );
        },
      ),
    );
  }
}
