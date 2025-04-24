import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesia_station_center_gms/page/homepage.dart';
import 'package:indonesia_station_center_gms/page/monitoring.dart';

class Profile extends StatefulWidget {
  final String username;

  const Profile({super.key, required this.username});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: -10,
              left: -10,
              child: Image.asset("assets/images/blue_arrow.png")),
          Positioned(
              top: 50,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                },
                child: Image.asset("assets/images/arrow.png"),
              )),
          Positioned(
              top: 100,
              left: -800,
              child: Image.asset("assets/images/profile_bg.png")),
          Positioned(
              top: 130,
              left: 10,
              child: Image.asset("assets/images/profile.png")),
          Positioned(
              top: 120,
              left: 100,
              child: Text(
                "Welcome!",
                style: GoogleFonts.lexend(color: Colors.white, fontSize: 25),
              )),
          Positioned(
              top: 140,
              left: 100,
              child: Text(
                widget.username,
                style: GoogleFonts.lexend(color: Colors.white, fontSize: 46),
              )),
          Positioned(
              top: 350,
              left: 30,
              child: Text(
                "Vehicles",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 34),
              )),
          Positioned(
              top: 400,
              left: 25,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Monitoring(username: widget.username)));
                },
                child: Image.asset("assets/images/grey_block.png"),
              )),
          Positioned(
              top: 410, left: 30, child: Image.asset("assets/images/car.png")),
          Positioned(
              top: 460,
              left: 150,
              child: Image.asset("assets/images/status.png")),
          Positioned(
              top: 410,
              left: 150,
              child: Text(
                "Cortez",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 34),
              ))
        ],
      ),
    );
  }
}
