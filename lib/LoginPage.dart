import 'dart:io';

import 'package:LearnTogether/UtilityComponents/AlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ColorConstants.dart' as colourconstants;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool loadingUser = false;

  @override
  void dispose() {
    // TODO: implement dispose
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        //just to make view scroll when keyboard shows up
        child: Stack(
          children: [
            generateBgImg('lightbluebg.png'),
            generateBgImg('darkbluebg.png'),
            middleLayer(),
            topLayer()
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget generateBgImg(String assetName) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/' + assetName,
              ),
              fit: BoxFit.fill,
            ),
          ),
        )
      ],
    );
  }

  Widget middleLayer() {
    TextStyle titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 60);
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 60, 30, 0),
      child: Text(
        "Learn \nTogether",
        style: titleStyle,
      ),
    );
  }

  Widget topLayer() {
    return loadingUser
        ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Card(
                    color: colourconstants.loginCardFormColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    child: Center(
                      child: formGroup(),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  Widget formGroup() {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailTextController,
            decoration: new InputDecoration(
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(12.0),
                  ),
                ),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(12.0),
                  ),
                ),
                filled: true,
                hintStyle: new TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
                hintText: "Email Address",
                fillColor: Colors.white70),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: true,
            controller: passwordTextController,
            decoration: new InputDecoration(
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(12.0),
                  ),
                ),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(12.0),
                  ),
                ),
                filled: true,
                hintStyle: new TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
                hintText: "Password",
                fillColor: Colors.white70),
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.transparent)),
            color: colourconstants.loginButtonColor,
            child: Text(
              "Sign In",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14),
            ),
            onPressed: () => handleSignInButtonPressed(),
          ),
        ],
      ),
    );
  }

  void handleSignInButtonPressed() async {
    setState(() {
      loadingUser = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);
    } catch (e) {
      showAlertDialog(context, "Authentication Error", e.message, [
        () {
          Navigator.of(context).pop();
        }
      ], [
        'Dismiss'
      ]);
    }
    setState(() {
      loadingUser = false;
    });
  }
}
