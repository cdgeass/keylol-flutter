class Profile {
  String? cookiePre;
  String? auth;
  String? saltKey;
  int? memberUid;
  String? memberUsername;
  String? memberAvatar;
  int? groupId;
  String? formHash;
  String? isModerator;
  int? readAccess;
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
    String? memberUidStr = json['memberuid'];
    if (memberUidStr != null) {
      memberUid = int.parse(memberUidStr);
    }
    memberUsername = json['memberusername'];
    memberAvatar = json['memberavatar'];
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
    Map<String, dynamic>? noticeJson = json['notice'];
    if (noticeJson != null) {
      notice = Notice.fromJson(noticeJson);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['cookiepre'] = this.cookiePre;
    data['auth'] = this.auth;
    data['saltkey'] = this.saltKey;
    data['memberuid'] = this.memberUid?.toString();
    data['memberusername'] = this.memberUsername?.toString();
    data['memberavatar'] = this.memberAvatar?.toString();
    data['groupid'] = this.groupId?.toString();
    data['formhash'] = this.formHash;
    data['ismoderator'] = this.isModerator;
    data['readaccess'] = this.readAccess?.toString();
    data['notice'] = this.notice?.toJson();
    return data;
  }
}

class Notice {
  int? newPush;
  int? newPm;
  int? newPrompt;
  int? newMyPost;

  Notice(this.newPush, this.newPm, this.newPrompt, this.newMyPost);

  Notice.fromJson(Map<String, dynamic> json) {
    newPush = json['newpush'];
    newPm = json['newpm'];
    newPrompt = json['newprompt'];
    newMyPost = json['newmypost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['newpush'] = this.newPush;
    data['newpm'] = this.newPm;
    data['newprompt'] = this.newPrompt;
    data['newmypost'] = this.newMyPost;
    return data;
  }
}
