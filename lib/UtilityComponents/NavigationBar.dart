import 'package:flutter/material.dart';
import '../ColorConstants.dart' as colourconstants;

class NavigationBar extends StatelessWidget {
  NavigationBar(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 120,
          color: colourconstants.backgroundColor,
        ),
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            height: 120,
            decoration: BoxDecoration(color: colourconstants.topBarColor),
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(this.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 45,
                          color: Colors.white)),
                ],
              )),
            ),
          ),
        ),
      ],
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height - 20);
    var controlPoint = Offset(size.width / 5, size.height);
    var endPoint = Offset(size.width / 2, size.height);
    var controlPoint2 = Offset(size.width * 4 / 5, size.height);
    var endPoint2 = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
