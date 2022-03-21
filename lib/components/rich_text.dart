import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/api/models/view_thread.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/auto_resize_video_player.dart';
import 'package:keylol_flutter/components/auto_resize_webview.dart';
import 'package:keylol_flutter/model/attachment.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

typedef ScrollToFunction = void Function(String pid);
typedef PollFallback = void Function();

class KRichTextBuilder {
  final String message;
  final Map<String, Attachment> attachments;
  final ScrollToFunction? scrollTo;

  final SpecialPoll? poll;
  final PollFallback? pollFallback;

  KRichTextBuilder(message,
      {this.attachments = const {},
      this.scrollTo,
      this.poll,
      this.pollFallback})
      : message =
            _formatMessage(HtmlUnescape().convert(message).trim(), attachments);

  static String _formatMessage(
      String message, Map<String, Attachment> attachments) {
    if (message.isEmpty) {
      return message;
    }
    // 转义
    message = HtmlUnescape().convert(message);

    message = message.replaceAll('<br>', '<br />');

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
    if (!message.contains('attach') && attachments.isNotEmpty) {
      for (var attachment in attachments.values) {
        message +=
            '<br /><img src="${attachment.url + attachment.attachment}" />';
      }
    } else {
      message = message
          .replaceAll('[attach]', '<attach>')
          .replaceAll('[/attach]', '</attach>');
    }

    // 倒计时
    message = message.replaceAllMapped(
        RegExp(r'(?:\[micxp_countdown)(?:=?)([^\[]*)]'), (match) {
      return '<countdown title="${match[1]}">';
    }).replaceAll('[/micxp_countdown]', '</countdown>');

    // 使用 https
    message = message.replaceAll('http://', 'https://');

    return message;
  }

  Widget build() {
    return KRichText(
      message: message,
      attachments: attachments,
      scrollTo: scrollTo,
    );
  }

  List<Widget> splitBuild() {
    final List<Widget> widgets = [];

    final document = HtmlParser.parseHTML(message);
    var html = '';
    for (var element in document.body!.nodes) {
      if (element is dom.Text) {
        html += element.data;
      } else if ((element is dom.Element) && element.localName != 'br') {
        html += element.outerHtml;
      } else {
        final trimmedHtml = html.trim();
        if (trimmedHtml.isNotEmpty) {
          widgets.addAll(_splitByIframe(trimmedHtml));
        }
        html = '';
      }
    }
    if (html.isNotEmpty) {
      widgets.addAll(_splitByIframe(html));
    }
    if (poll != null) {
      widgets.add(Poll(poll: poll!, callback: pollFallback));
    }

    return widgets;
  }

  List<Widget> _splitByIframe(String message) {
    final List<Widget> widgets = [];

    if (!_canSplit(message)) {
      // 如果在隐藏或折叠内容内则不切分
      widgets.add(_richText(
        message,
        attachments,
      ));
    } else {
      var lastIndex = 0;
      var index = 0;

      while (message.contains('iframe')) {
        index = message.indexOf('<iframe');
        if (index == -1) {
          break;
        }
        final beforeIframe = message.substring(lastIndex, index);
        if (beforeIframe != '\n' && beforeIframe.isNotEmpty) {
          widgets.add(_richText(
            beforeIframe,
            attachments,
          ));
        }

        lastIndex = index;

        index = message.indexOf('</iframe>') + 9;
        final iframe = message.substring(lastIndex, index);
        final document = HtmlParser.parseHTML(iframe);
        final element = document.body!.children[0];
        var url = element.attributes['src'] ?? '';
        if (!url.startsWith('http')) {
          if (url.startsWith('//')) {
            url = 'https:$url';
          } else {
            url = 'https://$url';
          }
        }
        widgets.add(AutoResizeWebView(
            padding: EdgeInsets.only(left: 16.0, right: 16.0), url: url));

        message = message.substring(index);
        lastIndex = 0;
        index = 0;
      }
      if (message.isNotEmpty) {
        widgets.add(_richText(
          message,
          attachments,
        ));
      }
    }

    return widgets;
  }

  bool _canSplit(String message) {
    return !(message.contains('spoil') ||
        message.contains('collapse') ||
        message.contains('blockquote'));
  }

  KRichText _richText(String message, Map<String, Attachment> attachments) {
    if (_canSplit(message) &&
        message.startsWith('<p>') &&
        message.endsWith('</p>')) {
      message = '<p>$message</p>';
    }
    return KRichText(
      message: message,
      attachments: attachments,
    );
  }
}

class KRichText extends StatefulWidget {
  final String message;
  final Map<String, Attachment> attachments;
  final ScrollToFunction? scrollTo;

  const KRichText(
      {Key? key,
      required this.message,
      this.attachments = const {},
      this.scrollTo})
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

  @override
  Widget build(BuildContext context) {
    return Html(
        data: widget.message,
        onLinkTap: (url, _, attributes, element) {
          if (url != null && url.startsWith('https://keylol.com/')) {
            url = HtmlUnescape().convert(url);
            final subUrl = url.replaceFirst('https://keylol.com/', '');
            if (subUrl.contains('findpost')) {
              final params = url.split('?')[1].split('&');
              late String pid;
              for (var param in params) {
                if (param.startsWith('pid=')) {
                  pid = param.replaceAll('pid=', '');
                  break;
                }
              }
              widget.scrollTo?.call(pid);
            } else if (subUrl.startsWith('t') && subUrl.endsWith('-1')) {
              final tid = subUrl.split('-')[0].replaceFirst('t', '');
              Navigator.of(context).pushNamed(
                '/thread',
                arguments: {'tid': tid},
              );
            } else if (subUrl.startsWith('f') && subUrl.endsWith('-1')) {
              final fid = subUrl.split('-')[0].replaceFirst('f', '');
              Navigator.of(context).pushNamed('/forum', arguments: fid);
            } else {
              Navigator.of(context).pushNamed('/webView', arguments: url);
            }
          } else {
            Navigator.of(context).pushNamed('/webView', arguments: url);
          }
        },
        tagsList: Html.tags
          ..addAll(['collapse', 'spoil', 'countdown', 'attach', 'blockquote']),
        customRender: {
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
          'video': (context, child) {
            final src = context.tree.element!.attributes['src']!;
            if (src.contains('www.bilibili.com')) {
              final splits = src.split('/');
              late String bv;
              if (src.endsWith('/')) {
                bv = splits[splits.length - 2];
              } else {
                bv = splits[splits.length - 1];
              }
              return AutoResizeWebView(
                  url:
                      'https://player.bilibili.com/player.html?high_quality=1&bvid=$bv&as_wide=1');
            }
            return AutoResizeVideoPlayer(initialUrl: src);
          },
          'collapse': (context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Collapse(
                title: title,
                message: message,
                attachments: widget.attachments);
          },
          'spoil': (context, child) {
            final title = context.tree.element!.attributes['title'] ?? '';
            final message = context.tree.element!.innerHtml;
            return _Spoil(
                title: title,
                message: message,
                attachments: widget.attachments);
          },
          'attach': (context, child) {
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
                    imageUrl: attachment.url + attachment.attachment));
          },
          'countdown': (context, child) {
            final date = context.tree.element!.text;

            return _CountDown(date: date);
          },
          'blockquote': (context, child) {
            return Column(
              children: [
                Row(
                  children: [
                    Image.asset('images/quote_proper_left.png'),
                    Expanded(child: Container())
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 24.0),
                    Expanded(child: child),
                    SizedBox(width: 24.0)
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    Image.asset('images/quote_proper_right.png')
                  ],
                )
              ],
            );
          }
        },
        customImageRenders: {
          (attr, _) => attr['src'] != null: networkImageRender(mapUrl: (url) {
            if (url!.startsWith('http://')) {
              return url.replaceFirst('http://', 'https://');
            } else if (!url.startsWith('http')) {
              return 'https://keylol.com/$url';
            } else {
              return url;
            }
          })
        },
        style: {
          'body': Style(margin: EdgeInsets.only(left: 16.0, right: 16.0)),
          'blockquote': Style(margin: EdgeInsets.zero)
        });
  }
}

// 折叠组件
class _Collapse extends StatefulWidget {
  final String title;
  final String message;
  final Map<String, Attachment> attachments;

  const _Collapse(
      {Key? key,
      required this.title,
      required this.message,
      required this.attachments})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CollapseState();
}

class _CollapseState extends State<_Collapse>
    with AutomaticKeepAliveClientMixin {
  bool _expanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.blue,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _expanded
                          ? Icon(Icons.arrow_drop_up, color: Colors.white)
                          : Icon(Icons.arrow_right, color: Colors.white),
                      Text(
                        widget.title,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
              if (_expanded)
                Material(
                    color: Theme.of(context).backgroundColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10.0))),
                    child: KRichText(
                        message: widget.message,
                        attachments: widget.attachments))
            ],
          ),
        ));
  }
}

// 折叠组件
class _Spoil extends StatefulWidget {
  final String title;
  final String message;
  final Map<String, Attachment> attachments;

  const _Spoil(
      {Key? key,
      required this.title,
      required this.message,
      required this.attachments})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpoilState();
}

class _SpoilState extends State<_Spoil> with AutomaticKeepAliveClientMixin {
  bool _expanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
        padding: EdgeInsets.all(8.0),
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
                            _expanded = !_expanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              _expanded
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
                  if (_expanded)
                    KRichText(
                      message: widget.message,
                      attachments: widget.attachments,
                    )
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

class _CountDownState extends State<_CountDown>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
  final SpecialPoll poll;
  final PollFallback? callback;

  const Poll({Key? key, required this.poll, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PollState();
}

class _PollState extends State<Poll> {
  final List<String> pollAnswers = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final pollTitle = Row(
      children: [
        widget.poll.multiple == '1'
            ? Text(
                '多选投票：',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                '单选投票，',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        if (widget.poll.multiple == '1')
          Text('最多可选${widget.poll.maxChoices}项，'),
        Text('共有 ${widget.poll.votersCount} 人参与投票')
      ],
    );
    children.add(pollTitle);
    var index = 1;
    for (final pollOption in widget.poll.pollOptions!) {
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

      final leading = widget.poll.allowVote!
          ? Checkbox(
              value: pollAnswers.contains(pollOption.pollOptionId!),
              onChanged: (value) {
                if (value!) {
                  if (!pollAnswers.contains(pollOption.pollOptionId!)) {
                    pollAnswers.add(pollOption.pollOptionId!);
                  }
                } else {
                  pollAnswers.remove(pollOption.pollOptionId!);
                }
                setState(() {});
              },
            )
          : null;
      final linearPercent = LinearPercentIndicator(
        width: MediaQuery.of(context).size.width - 100.0,
        lineHeight: 24.0,
        animation: true,
        animationDuration: 1000,
        percent: pollOption.percent! / 100,
        backgroundColor: Colors.transparent,
        progressColor: Color(int.parse('ff' + pollOption.color!, radix: 16)),
        leading: leading,
      );
      children.add(title);
      children.add(linearPercent);
      index++;
    }

    if (widget.poll.allowVote!) {
      children.add(Row(children: [
        ElevatedButton(
          child: Text('投票'),
          onPressed: () {
            if (pollAnswers.isNotEmpty) {
              KeylolClient()
                  .pollVote(widget.poll.tid!, pollAnswers)
                  .then((value) => widget.callback?.call());
            }
          },
        ),
        Expanded(child: Container())
      ]));
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: children,
      ),
    );
  }
}
