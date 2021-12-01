import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings {}

class LightColorSettings {
  static const backgroundColor = Color(0xFFF7F7F7);

  // tabBar
  static const tabBarIndicateColor = Colors.blueAccent;
  static const tabBarLabelColor = Colors.blueAccent;
  static const tarBarUnselectedLabelColor = Colors.black;
}

class SettingsHolder extends ChangeNotifier {
  Settings _settings = Settings();

  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }
}
