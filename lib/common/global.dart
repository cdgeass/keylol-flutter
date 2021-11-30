import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/models/notice.dart';
import 'package:keylol_flutter/models/profile.dart';

class Global {
  static final keylolClient = KeylolClient();

  // 用户信息
  static final profileHolder = ProfileHolder();

  static final noticeHolder = NoticeHolder();

  static Future init() async {
    await keylolClient.init();

    try {
      var profile = await keylolClient.fetchProfile(cached: false);
      profileHolder.setProfile(profile);
    } catch (ignored) {}
  }

  static logout() {
    keylolClient.cj.deleteAll();
    profileHolder.setProfile(null);
  }
}

class ProfileHolder extends ChangeNotifier {
  Profile? profile;

  void setProfile(Profile? profile) {
    // auth 为空则未成功登录
    this.profile = profile?.auth == null ? null : profile;
    notifyListeners();
  }
}

class NoticeHolder extends ChangeNotifier {
  static final _empty = Notice(0, 0, 0, 0);

  Notice notice = _empty;

  void update(Notice notice) {
    this.notice = notice;

    notifyListeners();
  }

  void clear() {
    update(_empty);
  }
}
