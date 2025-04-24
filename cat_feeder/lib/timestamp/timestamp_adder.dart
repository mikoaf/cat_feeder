import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TimeStampProvider with ChangeNotifier {
  List<String> _timestamps = [];

  List<String> get timestamps => _timestamps;

  void addTimestamp() {
    final String timestamp =
        DateFormat('yyyy:mm:dd HH:mm:ss').format(DateTime.now());
    if (_timestamps.length > 2) {
      _timestamps.removeAt(0);
    }
    _timestamps.add(timestamp);
    notifyListeners();
  }
}
