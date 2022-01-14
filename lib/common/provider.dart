import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/theme.dart';
import 'package:keylol_flutter/models/favorite_thread.dart';
import 'package:keylol_flutter/models/notice.dart';
import 'package:keylol_flutter/models/profile.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? _themeData;

  ThemeProvider._internal();

  static late final _instance = ThemeProvider._internal();

  factory ThemeProvider() => _instance;

  void update(ThemeData themeData) {
    this._themeData = themeData;

    notifyListeners();
  }

  ThemeData get themeData => _themeData ?? blue;
}

class ProfileProvider extends ChangeNotifier {
  Profile? profile;

  ProfileProvider._internal();

  static late final _instance = ProfileProvider._internal();

  factory ProfileProvider() => _instance;

  void update(Profile? profile) {
    // auth 为空则未成功登录
    this.profile = (profile?.memberUid == null || profile?.memberUid == '0')
        ? null
        : profile;

    notifyListeners();
  }

  void clear() {
    update(null);
  }
}

class NoticeProvider extends ChangeNotifier {
  static final _empty = Notice(0, 0, 0, 0);

  Notice notice = _empty;

  NoticeProvider._internal();

  static late final _instance = NoticeProvider._internal();

  factory NoticeProvider() => _instance;

  void update(Notice notice) {
    this.notice = notice;

    notifyListeners();
  }

  void clear() {
    update(_empty);
  }
}

class FavoriteThreadsProvider extends ChangeNotifier {
  List<FavoriteThread> favoriteThreads = [];

  FavoriteThreadsProvider._internal();

  static late final _instance = FavoriteThreadsProvider._internal();

  factory FavoriteThreadsProvider() => _instance;

  void update(List<FavoriteThread> favoriteThreads) {
    this.favoriteThreads = favoriteThreads;

    notifyListeners();
  }

  void delete(String favId) {
    this.favoriteThreads = this
        .favoriteThreads
        .where((element) => element.favId != favId)
        .toList();

    notifyListeners();
  }
}
