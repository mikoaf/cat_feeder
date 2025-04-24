import 'dart:async';
import 'dart:io';
import 'package:cat_feeder/pages/timestamp.dart';
import 'package:cat_feeder/timestamp/timestamp_adder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  late MqttServerClient mqtt_client;
  bool isCatVisible = false;
  String catStatus = "There's no Cat";
  String catEat = "Waiting for a Cat";
  String currentFace = "face1.png";
  Timer? hideTimer;
  Timer? faceChangeTimer;
  List<String> timestamps = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    faceChanging();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> setupMqttClient() async {
    mqtt_client = MqttServerClient('broker.emqx.io', 'althaf_client123');
    mqtt_client.logging(on: true);
    mqtt_client.keepAlivePeriod = 60;
    mqtt_client.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('althaf_client123')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    mqtt_client.connectionMessage = connMessage;

    try {
      await mqtt_client.connect();
    } catch (e) {
      debugPrint('MQTT Failed to connect: $e}');
      return;
    }

    if (mqtt_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT Connected');
      subscribeToTopic('detect/kocheng');
    } else {
      debugPrint(
          'MQTT connection failed - status: ${mqtt_client.connectionStatus!.state}');
      mqtt_client.disconnect();
    }
  }

  void onDisconnected() {
    debugPrint('MQTT Disconected');
  }

  void subscribeToTopic(String topic) {
    mqtt_client.subscribe(topic, MqttQos.atMostOnce);
    mqtt_client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      final MqttPublishMessage message =
          messages![0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      debugPrint('Received message: $payload from topic: ${messages[0].topic}');
      if (payload == '1') {
        showCatForDuration(10);
        addTimestamp();
      }
    });
  }

  void addTimestamp() {
    Provider.of<TimeStampProvider>(context, listen: false).addTimestamp();
  }

  void showCatForDuration(int seconds) {
    setState(() {
      catStatus = "Cat Detected!";
      catEat = "Cat Still Eating ^_^";
      isCatVisible = true;
    });

    hideTimer?.cancel();
    hideTimer = Timer(Duration(seconds: seconds), () {
      setState(() {
        isCatVisible = false;
        catStatus = "There's no Cat";
        catEat = "Waiting for a Cat";
      });
    });
  }

  void faceChanging() {
    faceChangeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentFace == 'face1.png') {
          currentFace = 'face2.png';
        } else if (currentFace == 'face2.png') {
          currentFace = 'face3.png';
        } else {
          currentFace = 'face1.png';
        }
      });
    });
  }

  Future<void> openCamera() async {
    // debugPrint('haha');
    if (await Permission.camera.isGranted) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        try {
          Directory? appDir = Directory('/storage/emulated/0/DCIM/Camera');
          if (!appDir.existsSync()) {
            appDir.createSync(recursive: true);
          }
          String appPath = appDir.path;

          String filename =
              DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
          File savedImage = File('$appPath/$filename');

          await File(photo.path).copy(savedImage.path);
          debugPrint('Picture saved to: ${savedImage.path}');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Picture saved'),
                  content: Text('Image saved at: ${savedImage.path}'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'))
                  ],
                );
              });
        } catch (e) {
          debugPrint('Failed to save picture: $e');
        }
      } else {
        debugPrint('No Picture taken.');
      }
    } else {
      debugPrint('Camera permission not granted');
    }
  }

  @override
  void dispose() {
    mqtt_client.disconnect();
    hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7ff0ba),
      body: Stack(
        children: [
          Positioned(
              top: 40,
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
              top: 100,
              left: 50,
              child: Image.asset('assets/images/big_block_.png')),
          Positioned(
              top: 100,
              left: 100,
              child: Text(
                'Cat Feeder',
                style: GoogleFonts.asapCondensed(
                    color: Color(0xff2b63b7),
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              )),
          Align(
              alignment: Alignment(0, 0.05),
              child: Image.asset('assets/images/eclipse_bottom.png')),
          Positioned(
              top: 200,
              left: 70,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/circle.png'))),
              )),
          Positioned(
              top: 490,
              left: 110,
              child: Image.asset('assets/images/small_block_.png')),
          Positioned(
              top: 490,
              left: 135,
              child: Text(catStatus,
                  style: GoogleFonts.asapCondensed(
                      color: Color(0xff2b63b7),
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          Positioned(
              top: 550,
              left: 10,
              child: Image.asset('assets/images/white_block.png')),
          Positioned(
              top: 570,
              left: 170,
              child: Image.asset('assets/images/$currentFace')),
          Positioned(
              top: 630,
              left: 10,
              child: Image.asset('assets/images/green_block.png')),
          Positioned(
              top: 630,
              left: 135,
              child: Text(catEat,
                  style: GoogleFonts.asapCondensed(
                      color: Color(0xff2b63b7),
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          Positioned(
              top: 680,
              left: 10,
              child: Image.asset('assets/images/blue_block.png')),
          if (isCatVisible)
            Positioned(
                top: 170,
                left: 10,
                child: Image.asset('assets/images/cat.png')),
          Positioned(
            top: 680,
            left: 100,
            child: Image.asset('assets/images/button_blue.png'),
          ),
          Positioned(
              top: 685,
              left: 140,
              child: GestureDetector(
                onTap: openCamera,
                child: Text(
                  'Take a Picture!',
                  style: GoogleFonts.asapCondensed(
                      color: Color(0xfff5f5f5),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              )),
          Positioned(
              top: 755,
              left: 100,
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Timestamp()));
                  },
                  child: Image.asset('assets/images/book_blue.png'))),
          Positioned(
              top: 763,
              left: 220,
              child: Image.asset('assets/images/cat_orange.png'))
        ],
      ),
    );
  }
}
