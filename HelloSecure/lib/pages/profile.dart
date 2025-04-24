import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hellosecure/pages/homepage.dart';
import 'package:hellosecure/pages/position.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xffa0bed7),
              Color(0xffe6cdaf),
              Color(0xfff0a0a0)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          Positioned(
              top: 40,
              left: 35,
              child: Text(
                "Your Profile",
                style: GoogleFonts.aBeeZee(
                    color: Colors.black,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0))
                    ]),
              )),
          Positioned(
              top: 150,
              left: 50,
              child: Image.asset(
                "assets/images/niqab_profile.png",
                height: 300,
                width: 300,
              )),
          Positioned(
            top: 450,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Deninda Laiqa",
                style: GoogleFonts.aBeeZee(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
              top: 550,
              left: 10,
              child: Text(
                "Username:",
                style: GoogleFonts.aBeeZee(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 630,
              left: 10,
              child: Text(
                "Email:",
                style: GoogleFonts.aBeeZee(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 750,
              left: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                },
                child: Image.asset(
                  'assets/images/hello_home.png',
                  height: 80,
                  width: 80,
                ),
              )),
          Positioned(
              top: 730,
              left: 160,
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StatusPos()));
                  },
                  child: Image.asset(
                    'assets/images/HelloSecure_logo_2.png',
                    height: 80,
                    width: 80,
                  ))),
          Positioned(
              top: 810,
              left: 175,
                child: Text(
                  'Status',
                  style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 15),
                ),
              ),
          Positioned(
              top: 750,
              left: 280,
              child: Image.asset(
                'assets/images/hello_profile.png',
                height: 80,
                width: 80,
              )),
        ],
      ),
    );
  }
}
