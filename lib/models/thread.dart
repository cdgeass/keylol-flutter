import 'package:html_unescape/html_unescape.dart';

class Thread {
  // 帖子 id
  final String tid;

  // 版块 id
  final String fid;
  final String postTableId;
  final String typeId;
  final String sortId;
  final int readPerm;
  final int price;

  // 作者
  final String author;

  // 作者 id
  final String authorId;

  // 标题
  final String subject;

  // 时间
  final String dateline;

  // 最后回复时间
  final String lastPost;

  // 最后回复人
  final String lastPoster;

  // 查看数
  final int views;

  // 回复数
  final int replies;
  final int displayOrder;
  final String highlight;

  // 精华
  final bool digest;
  final int rate;
  final int special;
  final int attachment;
  final int moderated;
  final int closed;
  final int stickReply;

  // 支持数
  final int recommends;
  final int recommendAdd;
  final int recommendSub;
  final int heats;
  final String status;
  final int isGroup;

  // 收藏数
  final int favTimes;

  // 分享数
  final int shareTimes;
  final String stamp;
  final String icon;
  final String pushedAId;
  final String cover;
  final int replyCredit;
  final String relatedByTag;
  final int maxPosition;
  final String bgColor;
  final int comments;
  final int hidden;
  final int linkSubmit;
  final String threadTable;
  final String threadTableId;
  final int addViews;
  final int allReplies;
  final bool isArchived;
  final int archived;
  final String subjectEnc;
  final String shortSubject;
  final dynamic replyCreditRule;
  final String recommendLevel;
  final String heatLevel;
  final String relay;

  Thread.fromJson(Map<String, dynamic> json)
      : tid = json['tid'] ?? '',
        fid = json['fid'] ?? '',
        postTableId = json['posttableid'] ?? '',
        typeId = json['typeid'] ?? '',
        sortId = json['sortid'] ?? '',
        readPerm = int.parse(json['readperm'] ?? '0'),
        price = int.parse(json['price'] ?? '0'),
        author = json['author'] ?? '',
        authorId = json['authorid'] ?? '',
        subject = json['subject'] ?? '',
        dateline = HtmlUnescape().convert(json['dateline'] ?? ''),
        lastPost = json['lastpost'] ?? '',
        lastPoster = json['lastposter'] ?? '',
        views = int.parse(json['views'] ?? '0'),
        replies = int.parse(json['replies'] ?? '0'),
        displayOrder = int.parse(json['displayorder'] ?? '0'),
        highlight = json['hightlight'] ?? '',
        digest = json['digest'] == '1',
        rate = int.parse(json['rate'] ?? '0'),
        special = int.parse(json['special'] ?? '0'),
        attachment = int.parse(json['attachment'] ?? '0'),
        moderated = int.parse(json['moderated'] ?? '0'),
        closed = int.parse(json['closed'] ?? '0'),
        stickReply = int.parse(json['stickreply'] ?? '0'),
        recommends = int.parse(json['recommends'] ?? '0'),
        recommendAdd = int.parse(json['recommends_add'] ?? '0'),
        recommendSub = int.parse(json['recommends_sub'] ?? '0'),
        heats = int.parse(json['heats'] ?? '0'),
        status = json['status'] ?? '',
        isGroup = int.parse(json['isgroup'] ?? '0'),
        favTimes = int.parse(json['favtimes'] ?? '0'),
        shareTimes = int.parse(json['sharetimes'] ?? '0'),
        stamp = json['stamp'] ?? '',
        icon = json['icon'] ?? '',
        pushedAId = json['pushedaid'] ?? '',
        cover = json['cover'] ?? '',
        replyCredit = int.parse(json['replycredit'] ?? '0'),
        relatedByTag = json['relatedbytag'] ?? '',
        maxPosition = int.parse(json['maxposition'] ?? '0'),
        bgColor = json['bgcolor'] ?? '',
        comments = int.parse(json['comments'] ?? '0'),
        hidden = int.parse(json['hidden'] ?? '0'),
        linkSubmit = int.parse(json['linksubmit'] ?? '0'),
        threadTable = json['threadtable'] ?? '',
        threadTableId = json['threadtableid'] ?? '',
        addViews = int.parse(json['addviews'] ?? '0'),
        allReplies = int.parse(json['allreplies'] ?? '0'),
        isArchived = json['is_archived'] == '1',
        archived = int.parse(json['archived'] ?? '0'),
        subjectEnc = json['subjectenc'] ?? '',
        shortSubject = json['short_subject'] ?? '',
        replyCreditRule = json['replycredit_rule'] ?? {},
        recommendLevel = json['recommendlevel'] ?? '',
        heatLevel = json['heatlevel'] ?? '',
        relay = json['relay'] ?? '';
}

class HotThread {
  // 帖子 id
  final String tid;

  // 版块 id
  final String fid;
  final String postTableId;
  final String typeId;
  final String sortId;
  final int readPerm;
  final int price;

  // 作者
  final String author;

  // 作者 id
  final String authorId;

  // 标题
  final String subject;

  // 时间
  final String dateline;

  // 最后回复时间
  final String lastPost;

  // 最后回复人
  final String lastPoster;

  // 查看数
  final int views;

  // 回复数
  final int replies;
  final int displayOrder;
  final String highlight;

  // 精华
  final bool digest;
  final int rate;
  final int special;
  final int attachment;
  final int moderated;
  final int closed;
  final int stickReply;

  // 支持数
  final int recommends;
  final int recommendAdd;
  final int recommendSub;
  final int heats;
  final String status;
  final int isGroup;

  // 收藏数
  final int favTimes;

  // 分享数
  final int shareTimes;
  final String stamp;
  final String icon;
  final String pushedAId;
  final String cover;
  final int replyCredit;
  final String relatedByTag;
  final int maxPosition;
  final String bgColor;
  final int comments;
  final int hidden;
  final int linkSubmit;
  final String lastPosterEnc;
  final String typeName;
  final String multiPage;
  final int pages;
  final String recommendIcon;

  // final int new;
  final int heatLevel;
  final int moved;
  final String iconTid;
  final String folder;
  final String weekNew;
  final bool isToday;
  final String dbDateline;
  final String dbLastPost;
  final String id;
  final String rushReply;
  final String avatar;

  HotThread.fromJson(Map<String, dynamic> json)
      : tid = json['tid'] ?? '',
        fid = json['fid'] ?? '',
        postTableId = json['posttableid'] ?? '',
        typeId = json['typeid'] ?? '',
        sortId = json['sortid'] ?? '',
        readPerm = int.parse(json['readperm'] ?? '0'),
        price = int.parse(json['price'] ?? '0'),
        author = json['author'] ?? '',
        authorId = json['authorId'] ?? '',
        subject = json['subject'] ?? '',
        dateline = HtmlUnescape().convert(json['dateline'] ?? ''),
        lastPost = json['lastpost'] ?? '',
        lastPoster = json['lastposter'] ?? '',
        views = int.parse(json['views'] ?? '0'),
        replies = int.parse(json['replies'] ?? '0'),
        displayOrder = int.parse(json['displayorder'] ?? '0'),
        highlight = json['hightlight'] ?? '',
        digest = json['digest'] == '1',
        rate = int.parse(json['rate'] ?? '0'),
        special = int.parse(json['special'] ?? '0'),
        attachment = int.parse(json['attachment'] ?? '0'),
        moderated = int.parse(json['moderated'] ?? '0'),
        closed = int.parse(json['closed'] ?? '0'),
        stickReply = int.parse(json['stickreply'] ?? '0'),
        recommends = int.parse(json['recommends'] ?? '0'),
        recommendAdd = int.parse(json['recommends_add'] ?? '0'),
        recommendSub = int.parse(json['recommends_sub'] ?? '0'),
        heats = int.parse(json['heats'] ?? '0'),
        status = json['status'] ?? '',
        isGroup = int.parse(json['isgroup'] ?? '0'),
        favTimes = int.parse(json['favtimes'] ?? '0'),
        shareTimes = int.parse(json['sharetimes'] ?? '0'),
        stamp = json['stamp'] ?? '',
        icon = json['icon'] ?? '',
        pushedAId = json['pushedaid'] ?? '',
        cover = json['cover'] ?? '',
        replyCredit = int.parse(json['replycredit'] ?? '0'),
        relatedByTag = json['relatedbytag'] ?? '',
        maxPosition = int.parse(json['maxposition'] ?? '0'),
        bgColor = json['bgcolor'] ?? '',
        comments = int.parse(json['comments'] ?? '0'),
        hidden = int.parse(json['hidden'] ?? '0'),
        linkSubmit = int.parse(json['linksubmit'] ?? '0'),
        lastPosterEnc = json['lastposterenc'] ?? '',
        typeName = json['typename'] ?? '',
        multiPage = json['multipage'] ?? '',
        pages = int.parse(json['pages'] ?? '0'),
        recommendIcon = json['recommendicon'] ?? '',
        // new = int.parse(json['new'] ?? '0'),
        heatLevel = int.parse(json['heatlevel'] ?? '0'),
        moved = int.parse(json['moved'] ?? '0'),
        iconTid = json['icontid'] ?? '',
        folder = json['folder'] ?? '',
        weekNew = json['weeknew'] ?? '',
        isToday = json['istoday'] == '1',
        dbDateline = json['dbdateline'] ?? '',
        dbLastPost = json['dblastpost'] ?? '',
        id = json['id'] ?? '',
        rushReply = json['rushreply'] ?? '',
        avatar = json['avatar'] ?? '';
}
