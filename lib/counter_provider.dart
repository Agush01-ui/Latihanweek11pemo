import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;
  int get count => _counter;

  CounterProvider() {
    _loadCounter();
  }

  void increment() {
    _counter++;
    _saveCounter();
    notifyListeners();
  }

  void decrement() {
    if (_counter > 0) {
      _counter--;
      _saveCounter();
      notifyListeners();
    }
  }

  void reset() {
    _counter = 0;
    _saveCounter();
    notifyListeners();
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_value', _counter);
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('counter_value') ?? 0;
    notifyListeners();
  }
}
