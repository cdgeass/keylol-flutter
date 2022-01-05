class Attachment {
  final String aid;
  final String tid;
  final String pid;
  final String uid;
  final String dateline;
  final String fileName;
  final String attachment;
  final int remote;
  final String description;
  final int readPerm;
  final int price;
  final bool isImage;
  final double width;
  final String thumb;
  final String picId;
  final String ext;
  final String imgAlt;
  final String attachIcon;
  final String attachSize;
  final String attachImg;
  final int payed;
  final String url;
  final String dbDateline;
  final String aidenCode;
  final int downloads;

  Attachment.fromJson(Map<String, dynamic> json)
      : aid = json['aid'] ?? '',
        tid = json['tid'] ?? '',
        pid = json['pid'] ?? '',
        uid = json['uid'] ?? '',
        dateline = json['dateline'] ?? '',
        fileName = json['filename'] ?? '',
        attachment = json['attachment'] ?? '',
        remote = int.parse(json['remote'] ?? '0'),
        description = json['description'] ?? '',
        readPerm = int.parse(json['readperm'] ?? '0'),
        price = int.parse(json['price'] ?? '0'),
        isImage = json['isimage'] == '1',
        width = double.parse(json['width'] ?? '0'),
        thumb = json['thumb'] ?? '',
        picId = json['picid'] ?? '',
        ext = json['ext'] ?? '',
        imgAlt = json['imgalt'] ?? '',
        attachIcon = json['attachicon'] ?? '',
        attachSize = json['attachsize'] ?? '',
        attachImg = json['attachimg'] ?? '',
        payed = int.parse(json['payed'] ?? '0'),
        url = json['url'] ?? '',
        dbDateline = json['dbdateline'] ?? '',
        aidenCode = json['aidencode'] ?? '',
        downloads = int.parse(json['downloads'] ?? '0');
}
