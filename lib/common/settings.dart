import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings {}

class SettingsHolder extends ChangeNotifier {
  Settings _settings = Settings();

  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }
}
