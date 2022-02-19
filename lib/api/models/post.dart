import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/model/attachment.dart';

class Post {
  // pid
  final String pid;

  // tid
  final String tid;

  // 是否一楼
  final bool first;

  // 作者
  final String author;

  // 作者id
  final String authorId;

  // 时间
  final String dateline;

  // 消息
  final String message;
  final int anonymous;
  final int attachment;
  final int status;

  // 作者
  final String username;
  final String adminId;
  final String groupId;
  final int memberStatus;

  // 楼层
  final int number;
  final int dbDateline;
  final Map<String, Attachment> attachments;
  final List<String> imageList;

  Post.fromJson(Map<String, dynamic> json)
      : pid = json['pid'] ?? '',
        tid = json['tid'] ?? '',
        first = json['first'] == '1',
        author = json['author'] ?? '',
        authorId = json['authorid'] ?? '',
        dateline = HtmlUnescape().convert(json['dateline'] ?? ''),
        message = HtmlUnescape().convert(json['message'] ?? ''),
        anonymous = int.parse(json['anonymous'] ?? '0'),
        attachment = int.parse(json['attachment'] ?? '0'),
        status = int.parse(json['status'] ?? '0'),
        username = json['username'] ?? '',
        adminId = json['adminid'],
        groupId = json['groupid'],
        memberStatus = int.parse(json['memberstatus'] ?? '0'),
        number = int.parse(json['number'] ?? '0'),
        dbDateline = int.parse(json['dbdateline'] ?? '0'),
        attachments = ((json['attachments'] ?? {}) as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key, Attachment.fromJson(value))),
        imageList = ((json['imagelist'] ?? []) as List<dynamic>)
            .map((i) => i as String)
            .toList();

  String? _pureMessage;

  String pureMessage() {
    if (_pureMessage != null) {
      return _pureMessage!;
    }

    final document = HtmlParser.parseHTML(message);

    _pureMessage = '';
    for (final node in document.body!.nodes) {
      if (node is dom.Text) {
        _pureMessage = _pureMessage! + node.text;
        if (_pureMessage!.length >= 100) break;
      } else if (node is dom.Element) {
        _pureMessage = _pureMessage! + node.text;
        if (_pureMessage!.length >= 100) break;
      }
    }

    if (_pureMessage!.length > 100) {
      _pureMessage = _pureMessage!.substring(0, 100) + '...';
      return _pureMessage!;
    }

    return _pureMessage!;
  }

}
