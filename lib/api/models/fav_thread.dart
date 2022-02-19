class FavThread {
  final String favId;
  final String uid;
  final String id;
  final String idType;
  final String spaceUid;
  final String title;
  final String description;
  final String dateline;
  final String icon;
  final String url;
  final int replies;
  final String author;

  FavThread.fromJson(Map<String, dynamic> json)
      : favId = json['favid'] ?? '',
        uid = json['uid'] ?? '',
        id = json['id'] ?? '',
        idType = json['idtype'] ?? '',
        spaceUid = json['spaceuid'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        dateline = json['dateline'] ?? '',
        icon = json['icon'],
        url = json['url'],
        replies = int.parse(json['replise'] ?? '0'),
        author = json['author'];
}
