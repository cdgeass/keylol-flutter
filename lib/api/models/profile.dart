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