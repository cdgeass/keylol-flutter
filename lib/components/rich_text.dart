import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/common/styling.dart';
import 'package:keylol_flutter/components/auto_resize_webview.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

class KRichText extends StatefulWidget {
  final String message;
  final Map<String, Attachment> attachments;

  const KRichText(
      {Key? key, required this.message, this.attachments = const {}})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _KRichTextState();
}

class _KRichTextState extends State<KRichText> {
  List<VideoPlayerController> _videoPlayerControllers = [];

  @override
  void dispose() {
    super.dispose();

    _videoPlayerControllers.forEach((controller) {
      controller.dispose();
    });
  }

  String _formatMessage(BuildContext context, String message) {
    if (message.isEmpty) {
      return message;
    }
    // 转义
    message = HtmlUnescape().convert(message);

    // 折叠内容
    message = message.replaceAllMapped(RegExp(r'(?:\[collapse)(?:=?)([^\]]*)]'),
        (match) {
      return '<collapse title="${match[1]}">';
    }).replaceAll('[/collapse]', '</collapse>');

    // 隐藏内容
    message = message.replaceAllMapped(RegExp(r'(?:\[spoil)(?:=?)([^\]]*)]'),
        (match) {
      return '<spoil title="${match[1]}">';
    }).replaceAll('[/spoil]', '</spoil>');

    // 去除iframe样式
    message = message.replaceAllMapped(RegExp(r'(style=")([^"]*)("></iframe>)'),
        (match) {
      return '${match[1]}${match[3]}';
    });

    // 视频
    message = message
        .replaceAll('[media]', '<video src="')
        .replaceAll('[/media]', '"></video>');

    // 附件
    if (!message.contains('attachimg') && widget.attachments.isNotEmpty) {
      for (var attachment in widget.attachments.values) {
        message +=
            '<br /><img src="${attachment.url! + attachment.attachment!}" />';
      }
    } else {
      message = message
          .replaceAll('[attachimg]', '<attachimg>')
          .replaceAll('[/attachimg]', '</attachimg>');
    }

    // 倒计时
    message = message.replaceAllMapped(
        RegExp(r'(?:\[micxp_countdown)(?:=?)([^\[]*)]'), (match) {
      return '<micxp_countdown title="${match[1]}">';
    }).replaceAll('[/micxp_countdown]', '</micxp_countdown>');

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Html(
        data: _formatMessage(context, widget.message),
        onLinkTap: (url, _, attributes, element) {
          if (url != null && url.startsWith('https://keylol.com/')) {
            final subUrl = url.replaceFirst('https://keylol.com/', '');
            if (subUrl.contains(".php")) {
              Navigator.of(context).pushNamed('/webview', arguments: url);
            } else if (subUrl.startsWith('t')) {
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
        tagsList: Html.tags
          ..addAll([
            'collapse',
            'spoil',
            'micxp_countdown',
            'blockquote',
            'attachimg'
          ]),
        customRender: {
          'collapse': (RenderContext context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Collapse(title: title, message: message);
          },
          'spoil': (context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Spoil(title: title, message: message);
          },
          'img': (context, child) {
            var src = context.tree.element!.attributes['src'];
            if (src != null) {
              src = src.replaceFirst('http://', 'https://');
              return Container(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          CircularProgressIndicator(),
                      imageUrl: src));
            }
            return null;
          },
          'attachimg': (context, child) {
            final attachmentId = context.tree.element!.innerHtml;

            final attachment = widget.attachments[attachmentId];
            if (attachment == null) {
              return Container();
            }

            return Container(
                padding: EdgeInsets.only(bottom: 8.0),
                child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        CircularProgressIndicator(),
                    imageUrl: attachment.url! + attachment.attachment!));
          },
          'video': (context, child) {
            var src = context.tree.element!.attributes['src'];
            if (src != null) {
              src = src.replaceFirst('http://', 'https://');
              var videoPlayerController = VideoPlayerController.network(src);
              _videoPlayerControllers.add(videoPlayerController);
              return Container(
                  padding: EdgeInsets.only(bottom: 8.0),
                  height: 320.0,
                  child: VideoPlayer(videoPlayerController));
            }
            return Container();
          },
          'iframe': (context, child) {
            final src = context.tree.element!.attributes['src'];
            if (src == null) {
              return Container();
            }

            if (src.startsWith('http')) {
              return AutoResizeWebView(url: src);
            }
            return Container();
          },
          'micxp_countdown': (context, child) {
            final date = context.tree.element!.text;

            return _CountDown(date: date);
          }
        },
        style: {
          'p': Style(padding: EdgeInsets.only(left: 8.0, right: 8.0)),
          '.reply_wrap': Style(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              border: Border.all(color: AppTheme.lightText))
        });
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
                          : Icon(Icons.arrow_right, color: Colors.white),
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
                  color: Theme.of(context).backgroundColor,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10.0))),
                  child: KRichText(message: widget.message),
                )
            ],
          ),
        ));
  }
}

// 折叠组件
class _Spoil extends StatefulWidget {
  final String title;
  final String message;

  const _Spoil({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpoilState();
}

class _SpoilState extends State<_Spoil> with RestorationMixin {
  RestorableBool _expanded = RestorableBool(false);

  @override
  String? get restorationId => 'spoil';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_expanded, 'expanded');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: DottedBorder(
            padding: EdgeInsets.all(4.0),
            dashPattern: [2.0],
            color: Colors.redAccent,
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      if (widget.title != "") Text(widget.title + ","),
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
                                  ? Text(
                                      '点击隐藏',
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline),
                                    )
                                  : Text(
                                      '点击显示',
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_expanded.value) KRichText(message: widget.message)
                ],
              ),
            )));
  }
}

// 倒计时
class _CountDown extends StatefulWidget {
  final String date;

  const _CountDown({Key? key, required this.date}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountDownState();
}

class _CountDownState extends State<_CountDown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: StreamBuilder(
            stream: _countDown(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                final duration = snapshot.data ?? '';

                return Text(duration);
              }
              return Container();
            },
          ),
        ));
  }

  Stream<String> _countDown() {
    return Stream.periodic(Duration(seconds: 1), (i) {
      final startDate = DateTime.now();
      var endDate = DateTime.parse(widget.date);

      var difference = endDate.difference(startDate);
      final days = difference.inDays;
      endDate = endDate.subtract(Duration(days: days));

      difference = endDate.difference(startDate);
      final hours = difference.inHours;
      endDate = endDate.subtract(Duration(hours: hours));

      difference = endDate.difference(startDate);
      final minutes = difference.inMinutes;
      endDate = endDate.subtract(Duration(minutes: minutes));

      difference = endDate.difference(startDate);
      final seconds = difference.inSeconds;

      return '$days天$hours小时$minutes分$seconds秒';
    });
  }
}

// 投票组件
class Poll extends StatefulWidget {
  final SpecialPoll specialPoll;

  const Poll({Key? key, required this.specialPoll}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PollState();
}

class _PollState extends State<Poll> {
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
