class Cat {
  String? fid;
  String? name;
  List<Forum>? forums;

  Cat.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    name = json['name'];
  }
}

class Forum {
  String? fid;
  String? name;
  int? threads;
  int? posts;
  int? todayPosts;
  String? description;
  String? icon;

  Forum.fromJson(Map<String, dynamic> json) {
    fid = json['fid'];
    name = json['name'];
    var threadsStr = json['threads'];
    if (threadsStr != null) {
      threads = int.parse(threadsStr);
    }
    var postsStr = json['posts'];
    if (postsStr != null) {
      posts = int.parse(postsStr);
    }
    var todayPostsStr = json['todayposts'];
    if (todayPostsStr != null) {
      todayPosts = int.parse(todayPostsStr);
    }
    description = json['description'];
    icon = json['icon'];
  }
}

class ForumThread {
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

  ForumThread.fromJson(Map<String, dynamic> json) {
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
    if (repliesStr != null) {
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
