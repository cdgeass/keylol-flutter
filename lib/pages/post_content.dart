import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

class PostContent extends StatelessWidget {
  final String message;
  final SpecialPoll? specialPoll;

  const PostContent({Key? key, required this.message, this.specialPoll})
      : super(key: key);

  String _formatMessage(String message) {
    // 折叠内容
    final collapseReg = RegExp(r'\[collapse=([^\]]*)]');
    if (collapseReg.hasMatch(message)) {
      final collapseMatches = collapseReg.allMatches(message);
      for (var collapseMatch in collapseMatches) {
        final title = collapseMatch.group(1);
        if (title != null) {
          message = message.replaceFirst(
              '[collapse=' + title + ']', '<collapse title="' + title + '">');
        }
      }
      message = message.replaceAll('[/collapse]', '</collapse>');
    }
    // 折叠内容
    final spoilReg = RegExp(r'\[spoil=([^\]]*)]');
    if (spoilReg.hasMatch(message)) {
      final spoilMatches = spoilReg.allMatches(message);
      for (var spoilMatch in spoilMatches) {
        final title = spoilMatch.group(1);
        if (title != null) {
          message = message.replaceFirst(
              '[spoil=' + title + ']', '<spoil title="' + title + '">');
        }
      }
      message = message.replaceAll('[/spoil]', '</spoil>');
    }
    return message
        .replaceAll('[media]', '<video src="')
        .replaceAll('[/media]', '"/>');
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Html(
        data: _formatMessage(message),
        onLinkTap: (url, _, attributes, element) {
          if (url != null && url.startsWith('https://keylol.com/')) {
            final subUrl = url.replaceFirst('https://keylol.com/', '');
            if (subUrl.startsWith('t')) {
              final tid = subUrl.split('-')[0].replaceFirst('t', '');
              Navigator.of(context).pushNamed('/thread', arguments: tid);
            } else if (subUrl.startsWith('f')) {
              final fid = subUrl.split('-')[0].replaceFirst('f', '');
              Navigator.of(context).pushNamed('/forum', arguments: fid);
            } else {
              Navigator.of(context).pushNamed('/webview', arguments: url);
            }
          } else {
            Navigator.of(context).pushNamed('/webview', arguments: url);
          }
        },
        tagsList: Html.tags..addAll(['collapse', 'spoil']),
        customRender: {
          'collapse': (RenderContext context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Collapse(title: title, message: message);
          },
          'spoil': (context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Collapse(title: title, message: message);
          },
          'img': (context, child) {
            var src = context.tree.element!.attributes['src'];
            if (src != null) {
              return CachedNetworkImage(
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircularProgressIndicator(),
                  imageUrl: src);
            }
            return null;
          },
          'video': (context, child) {
            var src = context.tree.element!.attributes['src'];
            if (src != null) {
              src = src.replaceFirst('http', 'https');
              var videoPlayerController = VideoPlayerController.network(src);
              return Container(
                  height: 320.0,
                  child: Chewie(
                    controller: ChewieController(
                        videoPlayerController: videoPlayerController,
                        autoInitialize: true,
                        autoPlay: true,
                        looping: false),
                  ));
            }
            return Container();
          }
        },
      ),
      if (specialPoll != null) _Poll(specialPoll: specialPoll!)
    ]);
  }
}

// 折叠组件
class _Collapse extends StatefulWidget {
  final String title;
  final String message;

  const _Collapse({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CollapseState();
}

class _CollapseState extends State<_Collapse> with RestorationMixin {
  RestorableBool _expanded = RestorableBool(false);

  @override
  String? get restorationId => 'collapse';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_expanded, 'expanded');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.blue,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded.value = !_expanded.value;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _expanded.value
                          ? Icon(Icons.arrow_drop_up, color: Colors.white)
                          : Icon(Icons.arrow_drop_down, color: Colors.white),
                      Text(
                        widget.title,
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              if (_expanded.value)
                Material(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10.0))),
                  child: PostContent(message: widget.message),
                )
            ],
          ),
        ));
  }
}

// 投票组件
class _Poll extends StatefulWidget {
  final SpecialPoll specialPoll;

  const _Poll({Key? key, required this.specialPoll}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PollState();
}

class _PollState extends State<_Poll> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final pollTitle = Row(
      children: [
        widget.specialPoll.multiple == '1'
            ? Text(
                '多选投票：',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                '单选投票，',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        if (widget.specialPoll.multiple == '1')
          Text('最多可选${widget.specialPoll.maxChoices}项，'),
        Text('共有 ${widget.specialPoll.votersCount} 人参与投票')
      ],
    );
    children.add(pollTitle);
    var index = 1;
    for (final pollOption in widget.specialPoll.pollOptions!) {
      final indexStr = index.toString() + '.';
      final title = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(indexStr + pollOption.pollOption!),
          Text(
            ' ${pollOption.percent!.toString()}%',
          ),
          Text(
            '(${pollOption.votes!.toString()})',
            style: TextStyle(
                color: Color(int.parse('ff' + pollOption.color!, radix: 16))),
          ),
        ],
      );
      final linearPercent = LinearPercentIndicator(
        width: MediaQuery.of(context).size.width - 16.0,
        lineHeight: 24.0,
        animation: true,
        animationDuration: 1000,
        percent: pollOption.percent! / 100,
        backgroundColor: Colors.transparent,
        progressColor: Color(int.parse('ff' + pollOption.color!, radix: 16)),
      );
      children.add(title);
      children.add(linearPercent);
      index++;
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: children,
      ),
    );
  }
}
