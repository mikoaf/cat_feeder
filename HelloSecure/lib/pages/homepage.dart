import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hellosecure/providers/mqtt_provider.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hellosecure/pages/position.dart';
import 'package:hellosecure/pages/profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late MqttServerClient client;
  String _currentTime = "";
  String _currentDate = "";
  String _temperature = "Loading...";
  String _weather = "Loading...";
  String _weatherIcon = "";
  List _newsArticles = [];
  String _weatherBg = "assets/images/sky/clear_sky.jpg";

  @override
  void initState() {
    super.initState();
    _updateTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqttProvider = Provider.of<MQTTProvider>(context, listen: false);
      _fetchWeather(mqttProvider);
    });
    _fetchNews();
  }

  String _backgroundWeather(String weather) {
    if (weather == "Sunny") {
      return "assets/images/sky/clear_sky.jpg";
    } else if (weather == "Partly cloudy" || weather == "Cloudy") {
      return "assets/images/weather_bg.png";
    } else if (weather == "Mist" || weather == "Fog") {
      return "assets/images/sky/cloudy_sky.jpg";
    } else if (weather == "Overcast" ||
        weather == "Patchy rain possible" ||
        weather == "Light rain shower" ||
        weather == "Moderate rain" ||
        weather == "Thundery outbreaks possible" ||
        weather == "Thunderstorm" ||
        weather == "Moderate or heavy rain with thunder") {
      return "assets/images/sky/rainy_sky.jpg";
    } else {
      return "assets/images/sky/clear_sky.jpg";
    }
  }

  void _launchWeatherApp(MQTTProvider mqttProvider) async {
    // Position position = await _determinePosition();
    double? lat = mqttProvider.latitude ?? 0;
    double? lon = mqttProvider.longitude ?? 0;
    final Uri url = Uri.parse('https://weather.com/weather/today/l/$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Couldn't launch URL";
    }
  }

  void _launchBMKG() async {
    final Uri url =
        Uri.parse('https://www.bmkg.go.id/gempabumi/gempabumi-realtime');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Couldn't launch URL";
    }
  }

  void _launchMapsApp(MQTTProvider mqttProvider) async {
    // Position position = await _determinePosition();
    double? lat = mqttProvider.latitude ?? 0;
    double? lon = mqttProvider.longitude ?? 0;
    final Uri url = Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Couldn't launch URL";
    }
  }

  void _launchCalendarApp() async {
    final Uri url = Uri.parse('content://com.android.calendar/time/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Couldn't launch URL";
    }
  }

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = TimeOfDay.now().format(context);
          _currentDate = DateFormat('EEEE, MMM dd yyyy').format(DateTime.now());
        });
      }
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Couldn't launch $url";
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

  Future<void> _fetchNews() async {
    String apiKey = "ceb6e8d390d548e78fd9bb5b6d17a37b";
    String apiUrl =
        "https://newsapi.org/v2/top-headlines?category=health&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _newsArticles = data["articles"];
        });
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  Future<void> _fetchWeather(MQTTProvider mqttProvider) async {
    try {
      // Position position = await _determinePosition();
      double? lat = mqttProvider.latitude;
      double? lon = mqttProvider.longitude;

      String apiKey = "24fb5953f5014c028a2150358250302";
      String apiUrl =
          "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&aqi=no";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = "${data['current']['temp_c']}°C";
          _weather = data['current']['condition']['text'];
          _weatherIcon = "https:${data['current']['condition']['icon']}";
          _weatherBg = _backgroundWeather(_weather);
        });
      } else {
        setState(() {
          _temperature = "Error";
          _weather = "Couldn't fetch weather";
          _weatherIcon = "";
          _weatherBg = _backgroundWeather(_weather);
        });
      }
    } catch (e) {
      setState(() {
        _temperature = "Error";
        _weather = "Couldn't fetch weather";
        _weatherIcon = "";
        _weatherBg = _backgroundWeather(_weather);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MQTTProvider>(context, listen: false);
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
            top: 100,
            left: 10,
            child: Image.asset(
              'assets/images/heart_logo.png',
              height: 40,
              width: 40,
            )),
        Positioned(
            top: 105,
            left: 60,
            child: Text(
              'Welcome to HelloSecure !',
              style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
        Positioned(
            top: 120,
            left: 60,
            child: Text(
              'Deninda Laiqa',
              style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
            top: 95,
            left: 290,
            child: Image.asset(
              'assets/images/niqab_profile.png',
              height: 80,
              width: 80,
            )),
        Positioned(
            top: 200,
            left: 20,
            child: Container(
                height: 200,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    image: DecorationImage(
                        image: AssetImage(_weatherBg), fit: BoxFit.cover)))),
        Positioned(
            top: 250,
            left: 40,
            child: Text(
              _currentTime,
              style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 50.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0))
                  ]),
            )),
        Positioned(
            top: 310,
            left: 40,
            child: Text(
              _currentDate,
              style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
            top: 245,
            left: 250,
            child: Text(
              _temperature,
              style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
            top: 270,
            left: 250,
            child: Container(
              height: 100,
              width: 100,
              child: Text(
                _weather,
                style: GoogleFonts.aBeeZee(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            )),
        Positioned(
            top: 350,
            left: 200,
            child: ElevatedButton(
                onPressed: (){
                  _fetchWeather(mqttProvider);
                },
                child: Text(
                  'Refresh Weather',
                  style: GoogleFonts.aBeeZee(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ))),
        Positioned(
            top: 230,
            left: 190,
            child: _weatherIcon.isNotEmpty
                ? Image.network(
                    _weatherIcon,
                    height: 60,
                    width: 60,
                  )
                : Image.asset(
                    "assets/images/weather/day_clear.png",
                    height: 50,
                    width: 50,
                  )),
        Positioned(
            top: 400,
            left: 30,
            child: Text(
              'Services',
              style: GoogleFonts.aBeeZee(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
            top: 450,
            left: 20,
            child: GestureDetector(
              onTap: (){
                _launchWeatherApp(mqttProvider);
              },
              child: Image.asset(
                'assets/images/hello_weather.png',
                height: 80,
                width: 80,
              ),
            )),
        Positioned(
            top: 450,
            left: 110,
            child: GestureDetector(
              onTap: (){
                _launchMapsApp(mqttProvider);
              },
              child: Image.asset(
                'assets/images/hello_maps.png',
                height: 80,
                width: 80,
              ),
            )),
        Positioned(
            top: 450,
            left: 200,
            child: GestureDetector(
              onTap: _launchBMKG,
              child: Image.asset(
                'assets/images/hello_warn.png',
                width: 80,
                height: 80,
              ),
            )),
        Positioned(
            top: 450,
            left: 290,
            child: GestureDetector(
              onTap: _launchCalendarApp,
              child: Image.asset(
                'assets/images/hello_date.png',
                height: 80,
                width: 80,
              ),
            )),
        Positioned(
            top: 540,
            left: 40,
            child: Text(
              'Latest News',
              style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )),
        Positioned(
            top: 530,
            left: 260,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(115, 10),
                    visualDensity: VisualDensity.compact),
                onPressed: _fetchNews,
                child: Text(
                  "Refresh News",
                  style: GoogleFonts.aBeeZee(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ))),
        Positioned(
            top: 570,
            left: 30,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 150,
                child: _newsArticles.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: _newsArticles.length,
                        itemBuilder: (context, index) {
                          final article = _newsArticles[index];
                          return Card(
                            child: ListTile(
                                leading: article["urlToImage"] != null
                                    ? Image.network(
                                        article["urlToImage"],
                                        width: 80,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        color: Colors.grey,
                                      ),
                                title: Text(
                                  article["title"] ?? "No Title",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    article["description"] ?? "No Description"),
                                onTap: () => _launchURL(article["url"])),
                          );
                        }))),
        Positioned(
            top: 750,
            left: 40,
            child: Image.asset(
              'assets/images/hello_home.png',
              height: 80,
              width: 80,
            )),
        Positioned(
            top: 730,
            left: 160,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StatusPos()));
                },
                child: Image.asset(
                  'assets/images/HelloSecure_logo_2.png',
                  height: 80,
                  width: 80,
                ))),
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
              )),
        )
      ],
    ));
  }
}
