class ForumDisplay {
  ForumDisplayForum? forum;
  ForumDisplayGroup? group;
  List<ForumDisplayThread>? threads;
  List<ForumDisplayThreadType>? threadTypes;

  ForumDisplay.fromJson(Map<String, dynamic> json) {
    var forumJson = json['forum'];
    if (forumJson != null) {
      forum = ForumDisplayForum.fromJson(forumJson);
    }
    var groupJson = json['group'];
    if (groupJson != null) {
      group = ForumDisplayGroup.fromJson(groupJson);
    }
    List<dynamic>? threadJsons = json['forum_threadlist'];
    if (threadJsons != null) {
      threads = threadJsons
          .map((threadJson) => ForumDisplayThread.fromJson(threadJson))
          .toList();
    }
    Map<String, dynamic>? threadTypesMap = json['threadtypes']?['types'];
    if (threadTypesMap != null) {
      threadTypes = new List.empty(growable: true);
      threadTypesMap.forEach((key, value) {
        threadTypes!.add(ForumDisplayThreadType(int.parse(key), value));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['forum'] = forum;
    data['group'] = group;
    data['forum_threadlist'] = threads;
    return data;
  }
}

class ForumDisplayGroup {
  String? groupId;
  String? groupTitle;

  ForumDisplayGroup.fromJson(Map<String, dynamic> json) {
    groupId = json['groupid'];
    groupTitle = json['grouptitle'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupid'] = groupId;
    data['grouptitle'] = groupTitle;
    return data;
  }
}

class ForumDisplayForum {
  String? fid;
  String? description;
  String? icon;
  String? rules;
  int? picStyle;
  int? fup;
  String? name;
  int? threads;
  int? posts;
  int? autoClose;
  int? threadCount;
  String? password;

  ForumDisplayForum.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    description = json['description'];
    icon = json['icon'];
    rules = json['rules'];
    var picStyleStr = json['picstyle'];
    if (picStyleStr != null) {
      picStyle = int.parse(picStyleStr);
    }
    var fupStr = json['fup'];
    if (fupStr != null) {
      fup = int.parse(fupStr);
    }
    name = json['name'];
    var threadsStr = json['threads'];
    if (threadsStr != null) {
      threads = int.parse(threadsStr);
    }
    var postsStr = json['posts'];
    if (postsStr != null) {
      posts = int.parse(postsStr);
    }
    var autoCloseStr = json['autoclose'];
    if (autoCloseStr != null) {
      autoClose = int.parse(autoCloseStr);
    }
    var threadCountStr = json['threadcount'];
    if (threadCountStr != null) {
      threadCount = int.parse(threadCountStr);
    }
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['fid'] = fid;
    data['description'] = description;
    data['icon'] = icon;
    data['rules'] = rules;
    data['picstype'] = picStyle?.toString();
    data['fup'] = fup?.toString();
    data['name'] = name;
    data['threads'] = threads?.toString();
    data['posts'] = posts?.toString();
    data['autoclose'] = autoClose?.toString();
    data['threadcount'] = threadCount?.toString();
    data['password'] = password;
    return data;
  }
}

class ForumDisplayThread {
  String? tid;
  int? typeId;
  int? readPerm;
  int? price;
  String? author;
  String? authorId;
  String? subject;
  String? dateLine;
  String? lastPost;
  String? lastPoster;
  int? view;
  int? replies;
  int? displayOrder;
  int? digest;
  int? special;
  int? attachment;
  int? recommendAdd;
  int? replayCredit;
  int? dbDateLine;
  int? dbLastPost;
  int? rushReply;
  int? recommend;

  ForumDisplayThread.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    var typeIdStr = json['typeid'];
    if (typeIdStr != null) {
      typeId = int.parse(typeIdStr);
    }
    var readPermStr = json['readperm'];
    if (readPermStr != null) {
      readPerm = int.parse(readPermStr);
    }
    var priceStr = json['price'];
    if (priceStr != null) {
      price = int.parse(priceStr);
    }
    author = json['author'];
    authorId = json['authorid'];
    subject = json['subject'];
    dateLine = json['dateline'];
    lastPost = json['lastpost'];
    lastPoster = json['lastposter'];
    var viewStr = json['view'];
    if (viewStr != null) {
      view = int.parse(viewStr);
    }
    var repliesStr = json['replies'];
    if (repliesStr != null && repliesStr != '-') {
      replies = int.parse(repliesStr);
    }
    var displayOrderStr = json['displayorder'];
    if (displayOrderStr != null) {
      displayOrder = int.parse(displayOrderStr);
    }
    var digestStr = json['digest'];
    if (digestStr != null) {
      digest = int.parse(digestStr);
    }
    var specialStr = json['special'];
    if (specialStr != null) {
      special = int.parse(specialStr);
    }
    var attachmentStr = json['attachment'];
    if (attachmentStr != null) {
      attachment = int.parse(attachmentStr);
    }
    var recommendAddStr = json['recommend_add'];
    if (recommendAddStr != null) {
      recommendAdd = int.parse(recommendAddStr);
    }
    var replyCreditStr = json['replyCredit'];
    if (replyCreditStr != null) {
      replayCredit = int.parse(replyCreditStr);
    }
    var dbDateLineStr = json['dbdateline'];
    if (dbDateLineStr != null) {
      dbDateLine = int.parse(dbDateLineStr);
    }
    var dbLastPostStr = json['dblastpost'];
    if (dbLastPostStr != null) {
      dbLastPost = int.parse(dbLastPostStr);
    }
    var rushReplyStr = json['rushreply'];
    if (rushReplyStr != null) {
      rushReply = int.parse(rushReplyStr);
    }
    var recommendStr = json['recommend'];
    if (recommendStr != null) {
      recommend = int.parse(recommendStr);
    }
  }
}

class ForumDisplayThreadType {
  final int id;
  final String name;

  ForumDisplayThreadType(this.id, this.name);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[id.toString()] = name;
    return data;
  }
}
