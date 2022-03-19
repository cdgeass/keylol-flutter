import 'package:keylol_flutter/api/models/notice.dart';

class NoticeRepository {
  Notice notice = Notice(0, 0, 0, 0);

  List<Function(Notice notice)> callbacks = [];

  void registerCallback(Function(Notice notice) callback) {
    callbacks.add(callback);
  }

  void update(Notice notice) {
    if (notice != this.notice) {
      this.notice = notice;
      for (var callback in callbacks) {
        callback.call(this.notice);
      }
    }
  }
}
