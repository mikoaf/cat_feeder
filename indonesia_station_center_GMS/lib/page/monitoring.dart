import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesia_station_center_gms/page/profile.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class Monitoring extends StatefulWidget {
  final String username;

  const Monitoring({super.key, required this.username});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  late MqttServerClient client;
  String CO = "XX";
  String smoke = "XX";
  String temp = "XX";
  String hum = "XX";
  String lat = "0";
  String lon = "0";
  String status = "Safe";
  String blockImage = "assets/images/long_green_block.png";

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  Future<void> connectMQTT() async {
    client = MqttServerClient.withPort("broker.emqx.io", "althafRasyad_flutter", 1883);
    String username = "airSafe";
    String password = "althafvsrasyad";

    client.logging(on: false);
    client.keepAlivePeriod = 120;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier("althafRasyad_flutter")
        .startClean()
        .authenticateAs(username, password)
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      debugPrint("Connection failed: $e");
      return;
    }
  }

  void _launchMapsApp() async {
    if (lat.isNotEmpty && lon.isNotEmpty) {
      final Uri url = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw "Couldn't launch URL";
      }
    } else {
      debugPrint("Coordinates not available");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Layanan lokasi tidak diaktifkan");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen');
    }

    return await Geolocator.getCurrentPosition();
  }

  void onConnected() {
    debugPrint("Connected to MQTT broker");
    client.subscribe('airsafe/mq7', MqttQos.atMostOnce);
    client.subscribe('airsafe/MQ2', MqttQos.atMostOnce);
    client.subscribe('airsafe/temp', MqttQos.atMostOnce);
    client.subscribe('airsafe/hum', MqttQos.atMostOnce);
    client.subscribe('airsafe/lat', MqttQos.atMostOnce);
    client.subscribe('airsafe/long', MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      for (var message in messages!) {
        final MqttPublishMessage recMessage =
        message.payload as MqttPublishMessage;
        final String payload =
        MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

        debugPrint('Received message: $payload from topic: ${message.topic}');

        setState(() {
          switch (message.topic) {
            case 'airsafe/mq7':
              CO = payload;
              break;
            case 'airsafe/MQ2':
              smoke = payload;
              break;
            case 'airsafe/temp':
              temp = payload;
              break;
            case 'airsafe/hum':
              hum = payload;
              break;
            case 'airsafe/lat':
              lat = payload;
              break;
            case 'airsafe/long':
              lon = payload;
              break;
          }
          checkSafety();
        });
      }
    });
  }

  void checkSafety() {
    double co = double.tryParse(CO) ?? 0;
    double tempe = double.tryParse(temp) ?? 0;
    double smokeLevel = double.tryParse(smoke) ?? 0;
    double humi = double.tryParse(hum) ?? 0;

    if (co >200 || tempe > 40 || smokeLevel > 130 || humi < 40) {
      status = "Warning";
      blockImage = "assets/images/red_long_block.png";
    } else {
      status = "Safe";
      blockImage = "assets/images/long_green_block.png";
    }
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Profile(username: widget.username)));
                },
                child: Image.asset("assets/images/arrow.png"),
              )),
          Positioned(
              top: 80,
              left: 100,
              child: Image.asset("assets/images/car_small.png")),
          Positioned(
              top: 200,
              left: 30,
              child: Text("Cortez",
                  style:
                      GoogleFonts.lexend(color: Colors.black, fontSize: 68))),
          Positioned(
              top: 300,
              left: 30,
              child: Image.asset("assets/images/big_status.png")),
          Positioned(
              top: 350,
              left: 30,
              child: Text(
                "GPS",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 26),
              )),
          Positioned(
              top: 380,
              left: 130,
              child: GestureDetector(
                onTap: _launchMapsApp,
                child: Image.asset("assets/images/maps_small.png"),
              )),
          Positioned(top: 550, left: -10, child: Image.asset(blockImage)),
          Positioned(
              top: 560,
              left: 180,
              child: Text(
                status,
                style: GoogleFonts.lexend(color: Colors.white, fontSize: 26),
              )),
          Positioned(
              top: 610,
              left: 40,
              child: Text(
                "Carbon Monoxide",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 630,
              left: 40,
              child: Text(
                CO,
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 660,
              left: 40,
              child: Text(
                "Temperature",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 680,
              left: 40,
              child: Text(
                temp,
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 610,
              left: 250,
              child: Text(
                "Smoke",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 630,
              left: 250,
              child: Text(
                smoke,
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 660,
              left: 250,
              child: Text(
                "Humidity",
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
          Positioned(
              top: 680,
              left: 250,
              child: Text(
                hum,
                style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),
              )),
        ],
      ),
    );
  }
}
