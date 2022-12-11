import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/models/notice.dart';

class Profile extends Equatable {
  final String? cookiePre;
  final String? auth;
  final String? saltKey;
  final String? memberUid;
  final String? memberUsername;
  final String? memberAvatar;
  final int? groupId;
  final String? formHash;
  final String? isModerator;
  final int? readAccess;
  final Notice? notice;

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
    this.notice,
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
        readAccess = int.parse(json['readaccess'] ?? '0'),
        notice = Notice.fromJson(json['notice'] ?? const {});

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
        notice,
      ];
}
