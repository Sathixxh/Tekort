import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceProvider with ChangeNotifier {
  bool _isPunchedIn = false;
  DateTime? _inTime;
  DateTime? _outTime; // <-- New

  bool get isPunchedIn => _isPunchedIn;
  DateTime? get inTime => _inTime;
  DateTime? get outTime => _outTime; // <-- New
  bool get hasPunchedToday {
  final now = DateTime.now();
  return _inTime != null &&
         _outTime != null &&
         _inTime!.year == now.year &&
         _inTime!.month == now.month &&
         _inTime!.day == now.day &&
         _outTime!.year == now.year &&
         _outTime!.month == now.month &&
         _outTime!.day == now.day;
}


  AttendanceProvider() {
    _loadPunchState();
  }

  void punchIn(DateTime time) async {
    _isPunchedIn = true;
    _inTime = time;
    _outTime = null; // Clear old outTime
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPunchedIn', true);
    await prefs.setString('inTime', _inTime!.toIso8601String());
  }

  void punchOut(DateTime time) async {
    _isPunchedIn = false;
    _outTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPunchedIn', false);
    await prefs.setString('outTime', _outTime!.toIso8601String());
    // Do not clear inTime here
  }

  Future<void> _loadPunchState() async {
    final prefs = await SharedPreferences.getInstance();
    _isPunchedIn = prefs.getBool('isPunchedIn') ?? false;
    final inTimeString = prefs.getString('inTime');
    final outTimeString = prefs.getString('outTime');

    if (inTimeString != null) {
      _inTime = DateTime.tryParse(inTimeString);
    }

    if (outTimeString != null) {
      _outTime = DateTime.tryParse(outTimeString);
    }

    notifyListeners();
  }
  
}
