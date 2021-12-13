import 'package:html_unescape/html_unescape.dart';

class ViewThread {
  String? fid;
  String? subject;
  int? replies;
  List<ViewThreadPost>? posts;

  ViewThread.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    subject = json['thread']['subject'];
    if (subject != null) {
      subject = HtmlUnescape().convert(subject!);
    }
    var repliesStr = json['thread']['replies'];
    if (repliesStr != null) {
      replies = int.parse(repliesStr);
    }
    SpecialPoll? specialPoll;
    var specialPollJson = json['special_poll'];
    if (specialPollJson != null) {
      specialPoll = SpecialPoll.fromJson(specialPollJson);
    }
    List<dynamic>? postJsons = json['postlist'];
    if (postJsons != null) {
      posts = postJsons.map((postJson) {
        final post = ViewThreadPost.fromJson(postJson);
        if (post.first == '1') {
          post.specialPoll = specialPoll;
        }
        return post;
      }).toList();
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
  Map<String, Attachment>? attachments;
  List<String>? imageList;
  SpecialPoll? specialPoll;

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
    var attachmentsMap = json['attachments'];
    if (attachmentsMap != null && attachmentsMap is Map) {
      attachments = {};
      attachmentsMap.forEach((key, value) {
        attachments![key] = Attachment.fromJson(value);
      });
    }
    var imageListTemp = json['imagelist'];
    if (imageListTemp != null && imageListTemp is List) {
      imageList = [];
      imageListTemp.forEach((element) {
        imageList!.add(element);
      });
    }
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

class Attachment {
  String? attachment;
  String? url;

  Attachment.fromJson(Map<String, dynamic> json) {
    attachment = json['attachment'];
    url = json['url'];
  }
}

class SpecialPoll {
  List<PollOption>? pollOptions;
  int? expirations;
  String? multiple;
  int? maxChoices;
  int? votersCount;
  int? visiblePoll;
  int? allowVote;
  int? remainTime;

  SpecialPoll.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? pollOptionJsons = json['polloptions'];
    if (pollOptionJsons != null) {
      pollOptions = pollOptionJsons.values
          .map((pollOptionJson) => PollOption.fromJson(pollOptionJson))
          .toList();
    }
    var expirationsStr = json['expirations'];
    if (expirationsStr != null) {
      expirations = int.parse(expirationsStr);
    }
    multiple = json['multiple'];
    var maxChoicesStr = json['maxchoices'];
    if (maxChoicesStr != null) {
      maxChoices = int.parse(maxChoicesStr);
    }
    var votersCountStr = json['voterscount'];
    if (votersCountStr != null) {
      votersCount = int.parse(votersCountStr);
    }
    var visiblePollStr = json['visiblepoll'];
    if (visiblePollStr != null) {
      visiblePoll = int.parse(visiblePollStr);
    }
  }
}

class PollOption {
  String? pollOptionId;
  String? pollOption;
  int? votes;
  String? width;
  double? percent;
  String? color;
  List<String>? imgInfo;

  PollOption.fromJson(Map<String, dynamic> json) {
    pollOptionId = json['polloptionid'];
    pollOption = json['polloption'];
    var votesStr = json['votes'];
    if (votesStr != null) {
      votes = int.parse(votesStr);
    }
    width = json['width'];
    var percentStr = json['percent'];
    if (percentStr != null) {
      percent = double.parse(percentStr);
    }
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['polloptionid'] = pollOptionId;
    data['polloption'] = pollOption;
    data['votes'] = votes?.toString();
    data['width'] = width?.toString();
    data['percent'] = percent?.toString();
    data['color'] = color;
    return data;
  }
}
