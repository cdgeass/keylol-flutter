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
    data['member_uid'] = this.memberUid;
    data['member_username'] = this.memberUsername?.toString();
    data['member_avatar'] = this.memberAvatar?.toString();
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
    var newPushStr = json['newpush'];
    if (newPushStr != null) {
      newPush = int.parse(newPushStr);
    }
    var newPmStr = json['newpm'];
    if (newPmStr != null) {
      newPm = int.parse(newPmStr);
    }
    var newPromptStr = json['newprompt'];
    if (newPromptStr != null) {
      newPrompt = int.parse(newPromptStr);
    }
    var newMyPostStr = json['newmypost'];
    if (newMyPostStr != null) {
      newMyPost = int.parse(newMyPostStr);
    }
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
