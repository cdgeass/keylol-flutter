class Post {
  // pid
  final String pid;

  // tid
  final String tid;

  // 是否一楼
  final bool first;

  // 作者
  final String author;

  // 作者id
  final String authorId;

  // 时间
  final String dateline;

  // 消息
  final String message;
  final int anonymous;
  final int attachment;
  final int status;

  // 作者
  final String username;
  final String adminId;
  final String groupId;
  final int memberStatus;

  // 楼层
  final int number;
  final int dbDateline;

  Post.fromJson(Map<String, dynamic> json)
      : pid = json['pid'] ?? '',
        tid = json['tid'] ?? '',
        first = json['first'] == '1',
        author = json['author'] ?? '',
        authorId = json['authorid'] ?? '',
        dateline = json['dateline'] ?? '',
        message = json['message'] ?? '',
        anonymous = int.parse(json['anonymous'] ?? '0'),
        attachment = int.parse(json['attachment'] ?? '0'),
        status = int.parse(json['status'] ?? '0'),
        username = json['username'] ?? '',
        adminId = json['adminid'],
        groupId = json['groupid'],
        memberStatus = int.parse(json['memberstatus'] ?? '0'),
        number = int.parse(json['number'] ?? '0'),
        dbDateline = int.parse(json['dbdateline'] ?? '0');
}
