import 'dart:ui';

import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/models/thread.dart';

class Space {
  final String uid;
  final String username;
  final int status;
  final int emailStatus;
  final int avatarStatus;
  final int videoPhotoStatus;
  final String adminId;
  final String groupId;
  final String groupExpiry;
  final String extGroupIds;
  final String regDate;
  final int credits;
  final String notifySound;
  final String timeOffset;
  final int newPm;
  final int newPrompt;
  final int accessMasks;
  final int allowAdminCp;
  final int onlyAcceptFriendPm;
  final int conisBind;
  final int freeze;
  final int extCredits1;
  final int extCredits2;
  final int extCredits3;
  final int extCredits4;
  final int extCredits5;
  final int extCredits6;
  final int extCredits7;
  final int extCredits8;
  final int friends;
  final int posts;
  final int threads;
  final int digestPosts;
  final String doings;
  final String blogs;
  final String albums;
  final String sharings;
  final String attachSize;
  final int views;
  final int olTime;
  final int todayAttachs;
  final int todayAttachSize;
  final int feeds;
  final int follower;
  final int following;
  final int newFollower;
  final int blackList;
  final String videoPhoto;
  final String spacename;
  final String spaceDescription;
  final String domain;
  final int addSize;
  final int addFriend;
  final int menuNum;
  final String theme;
  final String spaceCSS;
  final String blockPosition;
  final String recentNote;
  final String spaceNote;

  final List<Medal> medals;

  final String lastVisit;
  final String lastActivity;
  final String lastPost;

  final Group adminGroup;
  final Group group;

  final String? sigHtml;

  Space.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        username = json['username'],
        status = int.parse(json['status'] ?? '0'),
        emailStatus = int.parse(json['emailstatus'] ?? '0'),
        avatarStatus = int.parse(json['avatarstatus'] ?? '0'),
        videoPhotoStatus = int.parse(json['videophotostatus'] ?? '0'),
        adminId = json['adminid'],
        groupId = json['groupid'],
        groupExpiry = json['groupexpiry'],
        extGroupIds = json['extgroupids'],
        regDate = json['regdate'],
        credits = int.parse(json['credits'] ?? '0'),
        notifySound = json['notifysound'],
        timeOffset = json['timeoffset'],
        newPm = int.parse(json['newpm'] ?? '0'),
        newPrompt = int.parse(json['newprompt'] ?? '0'),
        accessMasks = int.parse(json['accessMasks'] ?? '0'),
        allowAdminCp = int.parse(json['allowadmincp'] ?? '0'),
        onlyAcceptFriendPm = int.parse(json['onlyaccessfriendpm'] ?? '0'),
        conisBind = int.parse(json['conisbind'] ?? '0'),
        freeze = int.parse(json['freeze'] ?? '0'),
        extCredits1 = int.parse(json['extcredits1'] ?? '0'),
        extCredits2 = int.parse(json['extcredits2'] ?? '0'),
        extCredits3 = int.parse(json['extcredits3'] ?? '0'),
        extCredits4 = int.parse(json['extcredits4'] ?? '0'),
        extCredits5 = int.parse(json['extcredits5'] ?? '0'),
        extCredits6 = int.parse(json['extcredits6'] ?? '0'),
        extCredits7 = int.parse(json['extcredits7'] ?? '0'),
        extCredits8 = int.parse(json['extcredits8'] ?? '0'),
        friends = int.parse(json['friends'] ?? '0'),
        posts = int.parse(json['posts'] ?? '0'),
        threads = int.parse(json['threads'] ?? '0'),
        digestPosts = int.parse(json['digestposts'] ?? '0'),
        doings = json['doings'],
        blogs = json['blogs'],
        albums = json['albums'],
        sharings = json['sharings'],
        attachSize = json['attachsize'],
        views = int.parse(json['views'] ?? '0'),
        olTime = int.parse(json['oltime'] ?? '0'),
        todayAttachs = int.parse(json['todayattachs'] ?? '0'),
        todayAttachSize = int.parse(json['todayattachsize'] ?? '0'),
        feeds = int.parse(json['feeds'] ?? '0'),
        follower = int.parse(json['follower'] ?? '0'),
        following = int.parse(json['following'] ?? '0'),
        newFollower = int.parse(json['newfollower'] ?? '0'),
        blackList = int.parse(json['blacklist'] ?? '0'),
        videoPhoto = json['videophoto'],
        spacename = json['spacename'],
        spaceDescription = json['spacedescription'],
        domain = json['domain'],
        addSize = int.parse(json['addsize'] ?? '0'),
        addFriend = int.parse(json['addfriend'] ?? '0'),
        menuNum = int.parse(json['menunum'] ?? '0'),
        theme = json['theme'],
        spaceCSS = json['spacecss'],
        blockPosition = json['blockposition'],
        recentNote = json['recentnote'],
        spaceNote = json['spacenote'],
        medals = _parseMedals(json['medals']),
        lastVisit = json['lastvisit'],
        lastActivity = json['lastactivity'],
        lastPost = json['lastpost'],
        adminGroup = Group.fromJson(json['admingroup'] ?? {}),
        group = Group.fromJson(json['group'] ?? {}),
        sigHtml = json['sightml'] != null
            ? HtmlUnescape().convert(json['sightml'])
            : null;

  static List<Medal> _parseMedals(dynamic medals) {
    if (medals == null || medals == '') {
      return [];
    }

    if (medals is List<dynamic>) {
      return medals.map((e) => Medal.fromJson(e)).toList();
    } else {
      return (medals as Map<String, dynamic>)
          .values
          .map((e) => Medal.fromJson(e))
          .toList();
    }
  }
}

class Privacy {}

class Medal {
  final String name;
  final String image;
  final String description;
  final String medalId;

  Medal.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        image = json['image'] ?? '',
        description = json['description'] ?? '',
        medalId = json['medalid'] ?? '';
}

class Group {
  static final _htmlReg = RegExp(r'<\/?.+?\/?>');
  static final _colorReg = RegExp(r'#([a-z0-9]{6})');
  static final _iconReg = RegExp(r'src="([^"]*)"');

  final String? type;
  final String? groupTitle;
  final int stars;
  final Color? color;
  final String? icon;
  final int readAccess;
  final String? allowGetAttach;
  final String? allowGetImage;
  final String? allowMediaCode;
  final int maxSigSize;
  final String? allowBeginCode;
  final int userStatusBy;

  Group.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        groupTitle = _parseHtml(json['grouptitle']),
        stars = int.parse(json['stars'] ?? '0'),
        color = _parseColor(json['color']),
        icon = _parseIcon(json['icon']),
        readAccess = int.parse(json['readaccess'] ?? '0'),
        allowGetAttach = json['allowgetattach'],
        allowGetImage = json['allowgetimage'],
        allowMediaCode = json['allowmediacode'],
        maxSigSize = int.parse(json['maxsigsize'] ?? '0'),
        allowBeginCode = json['allowbegincode'],
        userStatusBy = int.parse(json['userstatusby'] ?? '0');

  static String? _parseHtml(String? html) {
    if (html == null) {
      return null;
    }

    return html.replaceAll(_htmlReg, '');
  }

  static Color? _parseColor(String? color) {
    if (color == null) {
      return null;
    }

    final colorMatch = _colorReg.firstMatch(color);
    if (colorMatch != null) {
      return Color(int.parse('ff${colorMatch.group(1)}', radix: 16));
    }
    return null;
  }

  static String? _parseIcon(String? icon) {
    if (icon == null) {
      return null;
    }

    final iconMatch = _iconReg.firstMatch(HtmlUnescape().convert(icon));
    if (iconMatch != null) {
      return iconMatch.group(1);
    }
    return null;
  }
}

class SpaceThread {
  List<Thread> threadList = [];

  SpaceThread.fromDocument(Document document) {
    final tl = document.getElementsByClassName('tl')[0];

    final trs = tl.getElementsByTagName('tr');

    for (final tr in trs) {
      final clazz = tr.attributes['class'];
      if (clazz == 'th') {
        continue;
      }
      if (tr.innerHtml.contains('还没有相关的帖子')) {
        continue;
      }

      // 帖子
      final thA = tr.getElementsByTagName('th')[0].getElementsByTagName('a')[0];

      final tid = thA.attributes['href']!.split('-')[0].replaceFirst('t', '');
      final subject = thA.text;

      final tds = tr.getElementsByTagName('td');

      // 版块
      final td2A = tds[1].getElementsByTagName('a')[0];

      final fid = td2A.attributes['href']!.split('-')[0].replaceFirst('f', '');

      // 统计
      final replies = tds[2].getElementsByTagName('a')[0].text;
      final views = tds[2].getElementsByTagName('em')[0].text;

      threadList.add(Thread.fromJson({
        'fid': fid,
        'tid': tid,
        'subject': subject,
        'replies': replies,
        'views': views
      }));
    }
  }
}

class SpaceReply {
  List<SpaceReplyItem> replyList = [];

  SpaceReply.fromDocument(Document document) {
    final tl = document.getElementsByClassName('tl')[0];

    final trs = tl.getElementsByTagName('tr');

    for (var i = 1; i < trs.length;) {
      final thread = trs[i++];

      // 帖子
      final threadThA =
          thread.getElementsByTagName('th')[0].getElementsByTagName('a')[0];

      late String tid;
      threadThA.attributes['href']!
          .split('?')[1]
          .split('&')
          .forEach((attribute) {
        if (attribute.startsWith('ptid')) {
          tid = attribute.replaceFirst('ptid=', '');
          return;
        }
      });
      final subject = threadThA.text;

      do {
        final tr = trs[i];
        if (tr.attributes['class'] != null) {
          break;
        }

        final trA = tr.getElementsByTagName('a')[0];

        late String pid;
        trA.attributes['href']!.split('?')[1].split('&').forEach((attribute) {
          if (attribute.startsWith('pid')) {
            pid = attribute.replaceFirst('pid=', '');
            return;
          }
        });

        String message = trA.text;

        replyList.add(SpaceReplyItem(tid, pid, subject, message));

        i++;
      } while (i < trs.length);
    }
  }
}

class SpaceReplyItem {
  final String tid;
  final String pid;
  final String subject;
  final String message;

  SpaceReplyItem(this.tid, this.pid, this.subject, this.message);
}

class SpaceFriend {
  final List<Friend> friendList;
  final int count;

  SpaceFriend.fromJson(Map<String, dynamic> json)
      : friendList = ((json['list'] ?? []) as List<dynamic>)
            .map((e) => Friend.fromJson(e))
            .toList(),
        count = int.parse(json['count'] ?? '0');
}

class Friend {
  final String uid;
  final String username;

  Friend.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] ?? '',
        username = json['username'] ?? '';
}
