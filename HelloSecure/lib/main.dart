import 'package:flutter/material.dart';
import 'package:hellosecure/pages/homepage.dart';
import 'package:hellosecure/pages/position.dart';
import 'package:hellosecure/pages/profile.dart';
import 'package:hellosecure/pages/warning.dart';
import 'package:hellosecure/providers/mqtt_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => MQTTProvider())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MQTTProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => Homepage(),
          '/warning': (context) => Warning(),
          '/position': (context) => StatusPos(),
          '/profile': (context) => Profile()
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
