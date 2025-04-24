import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Warning extends StatefulWidget {
  const Warning({super.key});

  @override
  State<Warning> createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Positioned(
              top: 200,
              left: 50,
              child: Image.asset(
                'assets/images/warning.png',
                height: 300,
                width: 300,
              )),
          Positioned(
              top: 450,
              left: 70,
              child: Text(
                'Emergency button',
                style: GoogleFonts.aBeeZee(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              )),
          Positioned(
              top: 480,
              left: 100,
              child: Text(
                'was pressed!',
                style: GoogleFonts.aBeeZee(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ))
        ],
      ),
    );
  }
}
