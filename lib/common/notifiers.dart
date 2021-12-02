import 'package:flutter/material.dart';
import 'package:keylol_flutter/models/notice.dart';
import 'package:keylol_flutter/models/profile.dart';

class ProfileNotifier extends ChangeNotifier {
  Profile? profile;

  ProfileNotifier._internal();

  static late final _instance = ProfileNotifier._internal();

  factory ProfileNotifier() => _instance;

  void update(Profile? profile) {
    // auth 为空则未成功登录
    this.profile = profile?.auth == null ? null : profile;

    notifyListeners();
  }

  void clear() {
    update(null);
  }
}

class NoticeNotifier extends ChangeNotifier {
  static final _empty = Notice(0, 0, 0, 0);

  Notice notice = _empty;

  NoticeNotifier._internal();

  static late final _instance = NoticeNotifier._internal();

  factory NoticeNotifier() => _instance;

  void update(Notice notice) {
    this.notice = notice;

    notifyListeners();
  }

  void clear() {
    update(_empty);
  }
}
