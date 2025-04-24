import 'package:cat_feeder/timestamp/timestamp_adder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cat_feeder/pages/homepage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => TimeStampProvider())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home_Page(),
    );
  }
}
