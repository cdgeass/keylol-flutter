import 'notice.dart';

class Profile {
  String? cookiePre;
  String? auth;
  String? saltKey;
  String? memberUid;
  String? memberUsername;
  String? memberAvatar;
  int? groupId;
  String? formHash;
  String? isModerator;
  int? readAccess;
  Space? space;
  Notice? notice;

  Profile(
      this.cookiePre,
      this.auth,
      this.saltKey,
      this.memberUid,
      this.memberUsername,
      this.memberAvatar,
      this.groupId,
      this.formHash,
      this.isModerator,
      this.readAccess,
      this.notice);

  Profile.fromJson(Map<String, dynamic> json) {
    cookiePre = json['cookiepre'];
    auth = json['auth'];
    saltKey = json['saltkey'];
    memberUid = json['member_uid'];
    memberUsername = json['member_username'];
    memberAvatar = json['member_avatar'];
    String? groupIdStr = json['groupid'];
    if (groupIdStr != null) {
      groupId = int.parse(groupIdStr);
    }
    formHash = json['formhash'];
    isModerator = json['ismoderator'];
    String? readAccessStr = json['readaccess'];
    if (readAccessStr != null) {
      readAccess = int.parse(readAccessStr);
    }
    var spaceJson = json['space'];
    if (spaceJson != null) {
      space = Space.forJson(spaceJson);
    }
    var noticeJson = json['notice'];
    if (noticeJson != null) {
      notice = Notice.fromJson(noticeJson);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['cookiepre'] = this.cookiePre;
    data['auth'] = this.auth;
    data['saltkey'] = this.saltKey;
    data['member_uid'] = this.memberUid;
    data['member_username'] = this.memberUsername?.toString();
    data['member_avatar'] = this.memberAvatar?.toString();
    data['groupid'] = this.groupId?.toString();
    data['formhash'] = this.formHash;
    data['ismoderator'] = this.isModerator;
    data['readaccess'] = this.readAccess?.toString();
    data['space'] = this.space?.toJson();
    data['notice'] = this.notice?.toJson();
    return data;
  }
}

class Space {
  String? uid;
  String? username;
  int? status;
  int? groupId;
  String? sigHtml;
  Group? group;

  Space.forJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    var statusStr = json['status'];
    if (statusStr != null) {
      status = int.parse(statusStr);
    }
    var groupIdStr = json['groupid'];
    if (groupIdStr != null) {
      groupId = int.parse(groupIdStr);
    }
    sigHtml = json['sightml'];
    var groupJson = json['group'];
    if (groupJson != null) {
      group = Group.fromJson(groupJson);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['username'] = this.username;
    data['status'] = this.status?.toString();
    data['groupid'] = this.groupId?.toString();
    data['sightml'] = this.sigHtml;
    data['group'] = this.group?.toJson();
    return data;
  }
}

class Group {
  static final _htmlReg = RegExp(r'<\/?.+?\/?>');
  static final _colorReg = RegExp(r'color="#([a-z0-9]{6})"');
  static final _iconReg = RegExp(r'icon="(.*)"');

  String? type;
  String? groupTitle;
  String? color;
  String? icon;
  int? readAccess;

  Group.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    String? groupTitleStr = json['grouptitle'];
    if (groupTitleStr != null) {
      final colorMatch = _colorReg.firstMatch(groupTitleStr);
      if (colorMatch != null) {
        color = 'ff' + colorMatch.group(1)!;
      }
      groupTitleStr = groupTitleStr.replaceAll(_htmlReg, '');
      groupTitle = groupTitleStr;
    }
    var iconStr = json['icon'];
    if (iconStr != null) {
      final iconMatch = _iconReg.firstMatch(iconStr);
      if (iconMatch != null) {
        icon = iconMatch.group(1);
      }
    }
    var readAccessStr = json['readaccess'];
    if (readAccessStr != null) {
      readAccess = int.parse(readAccessStr);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['grouptitle'] = this.groupTitle;
    data['color'] = this.color;
    data['icon'] = this.icon;
    data['readaccess'] = this.readAccess?.toString();
    return data;
  }
}
