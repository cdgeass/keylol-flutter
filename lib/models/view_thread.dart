class ViewThread {
  List<ViewThreadPost>? posts;

  ViewThread.fromJson(Map<String, dynamic> json) {
    List<dynamic>? postJsons = json['postlist'];
    if (postJsons != null) {
      posts = postJsons
          .map((postJson) => ViewThreadPost.fromJson(postJson))
          .toList();
    }
  }
}

class ViewThreadPost {
  String? pid;
  String? tid;
  String? first;
  String? author;
  String? authorId;
  String? dateline;
  String? message;
  String? anonymous;
  int? attachment;
  int? status;
  int? replyCredit;
  int? position;
  String? username;
  String? adminId;
  String? groupId;
  int? memberStatus;
  int? number;
  int? dbDateline;
  String? groupIconId;

  ViewThreadPost.fromJson(Map<String, dynamic> json) {
    pid = json['pid'];
    tid = json['tid'];
    first = json['first'];
    author = json['author'];
    authorId = json['authorid'];
    dateline = json['dateline'];
    message = json['message'];
    anonymous = json['anonymous'];
    var attachmentStr = json['attachment'];
    if (attachmentStr != null) {
      attachment = int.parse(attachmentStr);
    }
    var statusStr = json['status'];
    if (statusStr != null) {
      status = int.parse(statusStr);
    }
    var replyCreditStr = json['replycredit'];
    if (replyCreditStr != null) {
      replyCredit = int.parse(replyCreditStr);
    }
    var positionStr = json['position'];
    if (positionStr != null) {
      position = int.parse(positionStr);
    }
    username = json['username'];
    adminId = json['adminid'];
    groupId = json['groupid'];
    var memberStatusStr = json['memberstatus'];
    if (memberStatusStr != null) {
      memberStatus = int.parse(memberStatusStr);
    }
    var numberStr = json['number'];
    if (numberStr != null) {
      number = int.parse(numberStr);
    }
    var dbDatelineStr = json['dbdateline'];
    if (dbDatelineStr != null) {
      dbDateline = int.parse(dbDatelineStr);
    }
    groupIconId = json['groupiconid'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['pid'] = pid;
    data['tid'] = tid;
    data['first'] = first;
    data['author'] = author;
    data['authorid'] = authorId;
    data['dateline'] = dateline;
    data['message'] = message;
    data['anonymous'] = anonymous;
    data['attachment'] = attachment?.toString();
    data['status'] = status?.toString();
    data['replycredit'] = replyCredit?.toString();
    data['position'] = position?.toString();
    data['username'] = username;
    data['adminid'] = adminId;
    data['groupid'] = groupId;
    data['memberstatus'] = memberStatus?.toString();
    data['number'] = number;
    data['dbdateline'] = dbDateline?.toString();
    data['groupiconid'] = groupIconId?.toString();
    return data;
  }
}
