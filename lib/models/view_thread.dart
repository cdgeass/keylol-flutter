import 'package:keylol_flutter/models/post.dart';
import 'package:keylol_flutter/models/thread.dart';

class ViewThread {
  final String fid;
  final Thread thread;
  final List<Post> postList;
  final List<String> imageList;
  final SpecialPoll? specialPoll;

  ViewThread.fromJson(Map<String, dynamic> json)
      : fid = json['fid'] ?? '',
        thread = Thread.fromJson(json['thread'] ?? {}),
        postList = ((json['postlist'] ?? []) as List<dynamic>)
            .map((p) => Post.fromJson(p))
            .toList(),
        imageList = ((json['imagelist'] ?? []) as List<dynamic>)
            .map((i) => i as String)
            .toList(),
        specialPoll = json['special_poll'] != null
            ? SpecialPoll.fromJson(
                json['thread']?['tid'] ?? '', json['special_poll'])
            : null;
}

class SpecialPoll {
  String? tid;
  List<PollOption>? pollOptions;
  int? expirations;
  String? multiple;
  int? maxChoices;
  int? votersCount;
  int? visiblePoll;
  bool? allowVote;
  int? remainTime;

  SpecialPoll.fromJson(String tid, Map<String, dynamic> json) {
    this.tid = tid;
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
    allowVote = json['allowvote'] == '1';
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
