import 'package:cat_feeder/pages/homepage.dart';
import 'package:cat_feeder/timestamp/timestamp_adder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Timestamp extends StatefulWidget {
  const Timestamp({super.key});

  @override
  State<Timestamp> createState() => _TimestampState();
}

class _TimestampState extends State<Timestamp> {
  @override
  Widget build(BuildContext context) {
    final timestamps = Provider.of<TimeStampProvider>(context).timestamps;
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: Stack(
        children: [
          Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Exit'),
                            content: Text('Are you sure want to exit?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel')),
                              TextButton(
                                  onPressed: () => SystemNavigator.pop(),
                                  child: Text('Exit'))
                            ],
                          ));
                },
                child: Image.asset('assets/images/back_button.png'),
              )),
          Positioned(
              top: 150,
              left: 70,
              child: Image.asset('assets/images/Blue_ball.png')),
          Positioned(
              top: 250,
              left: 110,
              child: Image.asset('assets/images/cat_sleep.png')),
          Positioned(
              top: 405,
              left: 30,
              child: Text(
                'Timestamps Cat Feeder',
                style: GoogleFonts.asapCondensed(
                    color: Color(0xff2b63b7),
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              )),
          Positioned(
            top: 490,
            left: 60,
            child: Column(
              children: timestamps.reversed.toList().map((timestamp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/images/Button_blue_long.png'),
                      Text(
                        timestamp,
                        style: GoogleFonts.asapCondensed(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
              top: 680,
              left: 10,
              child: Image.asset('assets/images/blue_block.png')),
          Positioned(
              top: 755,
              left: 100,
              child: Image.asset('assets/images/book_orange.png')),
          Positioned(
              top: 763,
              left: 220,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Home_Page()));
                },
                child: Image.asset('assets/images/cat_blue.png'),
              ))
        ],
      ),
    );
  }
}
