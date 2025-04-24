import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hellosecure/main.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTProvider with ChangeNotifier {
  final _broker = 'broker.emqx.io';
  final _port = 1883;
  final _clientId =
      'helloSecure_' + DateTime.now().millisecondsSinceEpoch.toString();
  final _topic = 'helloSecure/data';
  String username = 'helloSecure';
  String password = '12345678';

  late MqttServerClient _client;

  double? latitude;
  double? longitude;
  double? suhu;
  double? accelX;
  double? accelY;
  double? accelZ;
  double? gyroX;
  double? gyroY;
  double? gyroZ;
  int? touch;

  Timer? warningTimer;
  bool isWarningActive = false;

  bool isConnected = false;

  set _touch(int newValue){
    touch = newValue;

    if(newValue == 1 && !isWarningActive){
      isWarningActive = true;

      navigatorKey.currentState?.pushNamed('/warning');

      warningTimer = Timer(Duration(seconds: 5), (){
        if(navigatorKey.currentState?.canPop() ?? false){
          navigatorKey.currentState?.pop();
        }
        isWarningActive = false;
      });
    }
    notifyListeners();
  }

  MQTTProvider() {
    _connectToBroker();
  }

  Future<void> _connectToBroker() async {
    _client = MqttServerClient(_broker, _clientId)
      ..port = _port
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;

    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .authenticateAs(username, password)
        .withWillQos(MqttQos.atMostOnce);

    try {
      await _client.connect();
    } catch (e) {
      print('Connection failed: $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      _subscribeToTopic(_topic);
    }
  }

  void _subscribeToTopic(String topic) {
    _client.subscribe(topic, MqttQos.atMostOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      _handleIncomingData(payload);
    });
  }

  void _handleIncomingData(String payload) {
    try {
      final data = json.decode(payload);

      latitude = (data['latitude'] ?? 0).toDouble();
      longitude = (data['longitude'] ?? 0).toDouble();
      suhu = (data['suhu'] ?? 0).toDouble();

      accelX = (data['accelX'] ?? 0).toDouble();
      accelY = (data['accelY'] ?? 0).toDouble();
      accelZ = (data['accelZ'] ?? 0).toDouble();

      gyroX = (data['gyroX'] ?? 0).toDouble();
      gyroY = (data['gyroY'] ?? 0).toDouble();
      gyroZ = (data['gyroZ'] ?? 0).toDouble();

      _touch = (data['touch'] ?? 0);

      notifyListeners();
    } catch (e) {
      print('Error parsing payload: $e');
    }
  }

  void _onDisconnected() {
    isConnected = false;
    notifyListeners();
    print('MQTT disconnected');
  }

  void _onConnected() {
    isConnected = true;
    notifyListeners();
    print('MQTT connected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void disconnect() {
    _client.disconnect();
  }
}
