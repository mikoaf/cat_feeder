import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesia_station_center_gms/page/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController _usernameController = TextEditingController();
    return Scaffold(
        body: Stack(
          children: [
            Positioned(
                top: 400,
                left: -200,
                child: Image.asset("assets/images/home_bg.png")),
            Positioned(
                top: -120,
                left: -200,
                child: Image.asset("assets/images/smoke_blue.png")),
            Positioned(
                top: 300,
                left: 60,
                child: Image.asset("assets/images/box_white.png")),
            Positioned(
              top: 370,
              left: 70,
              child: SizedBox(
                width: 250,
                height: 30,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: 430,
                left: 70,
                child: SizedBox(
                  width: 250,
                  height: 30,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(19))),
                  ),
                )),
            Positioned(
                top: 470,
                left: 130,
                child: GestureDetector(
                  onTap: () {
                    String username = _usernameController.text;
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => Profile(username: username)));
                  }, child: Image.asset("assets/images/button_green.png"),
                )),
            Positioned(
                top: 320,
                left: 76,
                child: Text(
                  "AIRSAFE-GPS",
                  style: GoogleFonts.lexend(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: 468,
                left: 187,
                child: Text(
                  "Login",
                  style: GoogleFonts.belanosima(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                ))
          ],
        ));
  }
}
