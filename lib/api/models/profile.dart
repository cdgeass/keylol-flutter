import 'package:equatable/equatable.dart';

class Profile extends Equatable {
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
  );

  Profile.fromJson(Map<String, dynamic> json)
      : cookiePre = json['cookiepre'],
        auth = json['auth'],
        saltKey = json['saltkey'],
        memberUid = json['member_uid'],
        memberUsername = json['member_username'],
        memberAvatar = json['member_avatar'],
        groupId = int.parse(json['groupId'] ?? '0'),
        formHash = json['formhash'],
        isModerator = json['ismoderator'],
        readAccess = int.parse(json['readaccess'] ?? '0');

  @override
  List<Object?> get props => [
        cookiePre,
        auth,
        saltKey,
        memberUid,
        memberUsername,
        memberAvatar,
        groupId,
        formHash,
        isModerator,
        readAccess,
      ];
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
