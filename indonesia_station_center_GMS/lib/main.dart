import 'package:flutter/material.dart';
import 'package:indonesia_station_center_gms/page/homepage.dart';
import 'package:indonesia_station_center_gms/page/monitoring.dart';
import 'package:indonesia_station_center_gms/page/profile.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}