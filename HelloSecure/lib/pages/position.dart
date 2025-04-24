import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hellosecure/pages/profile.dart';
import 'package:hellosecure/providers/mqtt_provider.dart';
import 'package:provider/provider.dart';

import 'homepage.dart';

class StatusPos extends StatefulWidget {
  const StatusPos({super.key});

  @override
  State<StatusPos> createState() => _StatusPosState();
}

class _StatusPosState extends State<StatusPos> {
  String _positionDesc(
      double acX, double acY, double acZ, double gyX, double gyY, double gyZ) {
    if (acX == 0 && acY == 0 && acZ == 0) {
      return "Stand";
    } else if (acX == 1 && acY == 2 && acZ == 3) {
      return "Sit";
    } else if (acX == 4 && acY == 5 && acZ == 6) {
      return "Lay";
    } else {
      return "Stand";
    }
  }

  String _positionImage(
      double acX, double acY, double acZ, double gyX, double gyY, double gyZ) {
    if (acX == 0 && acY == 0 && acZ == 0) {
      return "assets/images/stand.png";
    } else if (acX == 1 && acY == 2 && acZ == 3) {
      return "assets/images/sit.png";
    } else if (acX == 4 && acY == 5 && acZ == 6) {
      return "assets/images/lay.png";
    } else {
      return "assets/images/stand.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MQTTProvider>(context);
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
              top: 50,
              left: 20,
              child: Text(
                "Body Status",
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
              top: -50,
              left: -50,
              child: Image.asset(
                'assets/images/bg_2.png',
                height: 500,
                width: 500,
              )),
          Positioned(
              top: 150,
              left: 40,
              child: Image.asset(
                'assets/images/profile_mini.png',
                height: 80,
                width: 80,
              )),
          Positioned(
              top: 160,
              left: 100,
              child: Text(
                "Deninda's",
                style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 190,
              left: 50,
              child: Text(
                'Temperature',
                style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 150,
              left: 200,
              child: Image.asset(
                'assets/images/termo.png',
                height: 100,
                width: 100,
              )),
          Positioned(
              top: 140,
              left: 260,
              child: Text(
                '°C',
                style: GoogleFonts.aBeeZee(
                    color: Colors.red,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 180,
              left: 270,
              child: Text(
                mqttProvider.suhu?.toStringAsFixed(1) ?? '0',
                style: GoogleFonts.aBeeZee(
                    color: Colors.red,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
              top: 200,
              left: -10,
              child: Image.asset('assets/images/bg_1.png')),
          Consumer<MQTTProvider>(
            builder: (context, mqttProvider, _) {
              double acX = mqttProvider.accelX ?? 0;
              double acY = mqttProvider.accelY ?? 0;
              double acZ = mqttProvider.accelZ ?? 0;
              double gyX = mqttProvider.gyroX ?? 0;
              double gyY = mqttProvider.gyroY ?? 0;
              double gyZ = mqttProvider.gyroZ ?? 0;

              String positionIm = _positionImage(acX, acY, acZ, gyX, gyY, gyZ);
              String positionDes = _positionDesc(acX, acY, acZ, gyX, gyY, gyZ);

              return Stack(
                children: [
                  Positioned(
                    top: 180,
                    left: -10,
                    child: Image.asset(positionIm),
                  ),
                  Positioned(
                      top: 630,
                      left: 155,
                      child: Text(
                        positionDes,
                        style: GoogleFonts.aBeeZee(
                            color: Colors.black,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ))
                ],
              );
            },
          ),
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
              child: Image.asset(
                'assets/images/HelloSecure_logo_2.png',
                height: 80,
                width: 80,
              )),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Profile()));
                },
                child: Image.asset(
                  'assets/images/hello_profile.png',
                  height: 80,
                  width: 80,
                ),
              )),
        ],
      ),
    );
  }
}
