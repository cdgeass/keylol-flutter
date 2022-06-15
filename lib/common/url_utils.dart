import 'dart:convert';

class UrlUtils {
  static final googlePrefix = 'https://www.google.com/url?q=';

  static final threadRegex = new RegExp(r'^t(\d*)-(\d*)-(\d*)');
  static final threadPostRegex =
      new RegExp(r'^forum.php\?mod=redirect&goto=findpost&pid=(\d*)&ptid=(\d*)');
  static final spaceRegex = new RegExp(r'^suid-(\d*)');
  static final forumRegex = new RegExp(r'^f(\d*)-(\d*)');

  // 解析 url 返回对应路由和参数
  static Map<String, dynamic> resolveUrl(String url) {
    var subUrl = url;
    if (url.startsWith(googlePrefix)) {
      subUrl = url.replaceFirst(googlePrefix, '');
    }

    if (!subUrl.startsWith('https://keylol.com/')) {
      return {};
    }

    subUrl = subUrl.replaceFirst('https://keylol.com/', '');
    // thread
    if (threadRegex.hasMatch(subUrl)) {
      final match = threadRegex.firstMatch(subUrl)!;
      final tid = match[1];
      return {
        'router': '/thread',
        'arguments': {'tid': tid}
      };
    }
    // thread to post
    if (threadPostRegex.hasMatch(subUrl)) {
      final match = threadPostRegex.firstMatch(subUrl)!;
      final tid = match[2];
      final pid = match[1];
      return {
        'router': '/thread',
        'arguments': {'tid': tid, 'pid': pid}
      };
    }
    // space
    if (spaceRegex.hasMatch(subUrl)) {
      final match = spaceRegex.firstMatch(subUrl)!;
      final uid = match[1];
      return {'router': '/space', 'arguments': uid};
    }
    // forum
    if (forumRegex.hasMatch(subUrl)) {
      final match = forumRegex.firstMatch(subUrl)!;
      final fid = match[1];
      return {'router': '/forum', 'arguments': fid};
    }

    return {};
  }
}
