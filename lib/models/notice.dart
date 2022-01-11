class Notice {
  final int newPush;
  final int newPm;
  final int newPrompt;
  final int newMyPost;

  Notice(this.newPush, this.newPm, this.newPrompt, this.newMyPost);

  Notice.fromJson(Map<String, dynamic> json)
      : newPush = int.parse(json['newpush'] ?? '0'),
        newPm = int.parse(json['newpm'] ?? '0'),
        newPrompt = int.parse(json['newprompt'] ?? '0'),
        newMyPost = int.parse(json['newmypost'] ?? '0');

  Map<String, dynamic> toJson() => {
        'newpush': newPush,
        'newpm': newPm,
        'newprompt': newPrompt,
        'newmypost': newMyPost
      };

  int count() {
    return newPush + newPm + newPrompt + newMyPost;
  }
}

class NoteList {
  final int page;
  final int perPage;
  final int count;
  final List<Note> list;

  NoteList.fromJson(Map<String, dynamic> json)
      : page = int.parse(json['page'] ?? '0'),
        perPage = int.parse(json['perpage'] ?? '0'),
        count = int.parse(json['count'] ?? '0'),
        list = ((json['list'] ?? []) as List<dynamic>)
            .map((e) => Note.fromJson(e))
            .toList();
}

class Note {
  final String id;
  final String uid;
  final String type;

  // final int new;

  final String authorId;
  final String author;
  final String note;
  final int dateline;
  final String fromId;
  final String? fromIdType;
  final int fromNum;
  final NoteVar? noteVar;

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uid = json['uid'],
        type = json['type'],
        authorId = json['authorid'],
        author = json['author'] ?? '',
        note = json['note'],
        dateline = int.parse(json['dateline'] ?? '0'),
        fromId = json['from_id'],
        fromIdType = json['from_idtype'],
        fromNum = int.parse(json['from_num'] ?? '0'),
        noteVar =
            json['notevar'] == null ? null : NoteVar.fromJson(json['notevar']);
}

class NoteVar {
  final String tid;
  final String pid;
  final String subject;
  final String actorUid;
  final String actorUsername;

  NoteVar.fromJson(Map<String, dynamic> json)
      : tid = json['tid'],
        pid = json['pid'],
        subject = json['subject'],
        actorUid = json['actoruid'],
        actorUsername = json['actorusername'];
}
