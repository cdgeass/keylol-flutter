import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/common/url_utils.dart';
import 'package:keylol_flutter/components/auto_resize_video_player.dart';
import 'package:keylol_flutter/components/auto_resize_webview.dart';
import 'package:keylol_flutter/components/image_viewer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

typedef ScrollToFunction = void Function(String pid);
typedef PollCallback = void Function(BuildContext context);

class KRichTextBuilder {
  final String message;
  final Map<String, Attachment> attachments;
  final ScrollToFunction? scrollTo;

  final SpecialPoll? poll;
  final PollCallback? pollCallback;

  KRichTextBuilder(
    message, {
    this.attachments = const {},
    this.scrollTo,
    this.poll,
    this.pollCallback,
  }) : message =
            _formatMessage(HtmlUnescape().convert(message).trim(), attachments);

  static String _formatMessage(
    String message,
    Map<String, Attachment> attachments,
  ) {
    if (message.isEmpty) {
      return message;
    }
    // 转义
    message = HtmlUnescape().convert(message);

    // 替换所有换行符 方便后续处理
    message = message.replaceAll(RegExp(r'[\r\n]'), '<br />');

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

    final tempAttachments = <String, Attachment>{};
    attachments.forEach((key, value) {
      tempAttachments[key] = value;
    });
    // 附件
    message =
        message.replaceAllMapped(RegExp(r'\[attach](\d*)\[/attach]'), (match) {
      final aid = match[1];
      final attachment = tempAttachments[aid];
      if (attachment != null) {
        tempAttachments.remove(aid);
        return '<img src="${attachment.url + attachment.attachment}" />';
      }
      return '';
    });
    // 附件可能缺失
    for (final attachment in tempAttachments.values) {
      message +=
          '<br /><img src="${attachment.url + attachment.attachment}" />';
    }

    // 倒计时
    message = message.replaceAllMapped(
        RegExp(r'(?:\[micxp_countdown)(?:=?)([^\[]*)]'), (match) {
      return '<countdown title="${match[1]}">';
    }).replaceAll('[/micxp_countdown]', '</countdown>');

    // 使用 https
    message = message.replaceAll('http://', 'https://');

    // br 会导致高度计算异常
    message = message.replaceAll(RegExp(r'(<br\s?/>)+'), '<br/>');

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
    final List<String> contents = [];
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
          contents.add(html);
        }
        html = '';
      }
    }
    if (html.isNotEmpty) {
      contents.add(html);
    }
    final widgets = <Widget>[];
    for (final content in contents) {
      widgets.add(KRichText(message: content, attachments: attachments));
    }
    if (poll != null) {
      widgets.add(Poll(poll: poll!, callback: pollCallback));
    }

    return widgets;
  }
}

class KRichText extends StatefulWidget {
  final String message;
  final Map<String, Attachment> attachments;
  final ScrollToFunction? scrollTo;
  final bool enableMargin;

  const KRichText({
    Key? key,
    required this.message,
    this.attachments = const {},
    this.scrollTo,
    this.enableMargin = true,
  }) : super(key: key);

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
  Widget build(BuildContext buildContext) {
    return Html(
      data: widget.message,
      onLinkTap: (url, _, attributes, element) {
        url = HtmlUnescape().convert(url ?? '');
        final subUrl = url.replaceFirst('https://keylol.com/', '');
        if (subUrl.contains('findpost')) {
          // 帖子内楼层跳转
          final params = url.split('?')[1].split('&');
          late String pid;
          for (var param in params) {
            if (param.startsWith('pid=')) {
              pid = param.replaceAll('pid=', '');
              break;
            }
          }
          widget.scrollTo?.call(pid);
        } else {
          final resolveResult = UrlUtils.resolveUrl(url);
          if (resolveResult.isNotEmpty) {
            final router = resolveResult['router'];
            final arguments = resolveResult['arguments'];
            Navigator.of(buildContext).pushNamed(router, arguments: arguments);
          } else {
            launchUrlString(url, mode: LaunchMode.externalApplication);
          }
        }
      },
      tagsList: Html.tags
        ..addAll(['collapse', 'spoil', 'countdown', 'blockquote']),
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
            if (bv.contains("?")) {
              bv = bv.split('?')[0];
            }
            if (bv.contains('av')) {
              final av = bv.replaceAll('av', '');
              return AutoResizeWebView(
                  url:
                      'https://player.bilibili.com/player.html?high_quality=1&aid=$av&as_wide=1');
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
              title: title, message: message, attachments: widget.attachments);
        },
        'spoil': (context, child) {
          final title = context.tree.element!.attributes['title'] ?? '';
          final message = context.tree.element!.innerHtml;
          return _Spoil(
              title: title, message: message, attachments: widget.attachments);
        },
        'countdown': (context, child) {
          final date = context.tree.element!.text;

          return _CountDown(date: date);
        },
        'blockquote': (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
        },
        'table': (context, child) {
          var html = context.tree.element!.innerHtml;

          html = html.replaceAllMapped(
              RegExp(r'<table>((?!(<table>|</table>)).)+</table>'), (match) {
            final subMessage =
                match[0]!.replaceAll('<table>', '').replaceAll('</table>', '');

            final matches =
                RegExp(r'<tr>((?!(<tr>|</tr>)).)+</tr>').allMatches(subMessage);
            if (matches.isEmpty) {
              return subMessage;
            }
            if (matches.length == 1) {
              return matches.first[0]!.replaceAllMapped(
                  RegExp(r'<td>((?!(<td>|</td>)).)+</td>'), (match) {
                return match[0]!
                        .replaceAll('<td>', '')
                        .replaceAll('</td>', '') +
                    '<br/>';
              });
            }

            final titleRowMatch = matches.first;
            final titleMatches = RegExp(r'<th((?!(<th|</th>)).)+</th>')
                .allMatches(titleRowMatch[0]!);
            final titles = titleMatches
                .map((m) => m[0]!
                    .replaceAll(RegExp(r'<th[^>]+>'), '')
                    .replaceAll('</th>', ''))
                .toList();
            var start = 0;
            if (titles.isNotEmpty) {
              start = 1;
            }

            var str = '';
            var i = 0;
            for (final match in matches) {
              if (i >= start) {
                final rowMatches = RegExp(r'<td((?!(<td|</td>)).)+</td>')
                    .allMatches(match[0]!);
                var j = 0;
                for (var rowMatch in rowMatches) {
                  if (titles.isNotEmpty) {
                    final title = titles[j];
                    str += title + '<br/>';
                  }
                  str += rowMatch[0]!
                          .replaceAll(RegExp(r'<td[^>]+>'), '')
                          .replaceAll('</td>', '') +
                      '<br/>';
                  j++;
                }
                str += '<br/>';
              }
              i++;
            }
            return str;
          });
          return KRichTextBuilder(
            html,
            attachments: widget.attachments,
            scrollTo: widget.scrollTo,
          ).build();
        }
      },
      onImageTap: (url, context, attributes, element) {
        Navigator.push(
          buildContext,
          MaterialPageRoute(builder: (context) => ImageViewer(url: url!)),
        );
      },
      customImageRenders: {
        (attr, _) => attr['src'] != null: networkImageRender(
          mapUrl: (url) {
            if (url!.startsWith('http://')) {
              return url.replaceFirst('http://', 'https://');
            } else if (!url.startsWith('http')) {
              return 'https://keylol.com/$url';
            } else {
              return url;
            }
          },
        ),
      },
      style: {
        'body': Style(
          margin: widget.enableMargin
              ? EdgeInsets.only(left: 16.0, right: 16.0)
              : null,
        ),
        'blockquote': Style(margin: EdgeInsets.zero)
      },
    );
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
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final foregroundColor = Theme.of(context).colorScheme.onSurface;
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.0),
              bottom: !_expanded ? Radius.zero : Radius.circular(12.0),
            ),
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
                      ? Icon(Icons.arrow_drop_up, color: foregroundColor)
                      : Icon(Icons.arrow_right, color: foregroundColor),
                  Text(
                    widget.title,
                    style: TextStyle(color: foregroundColor),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
          if (_expanded)
            Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: backgroundColor),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12.0)),
              ),
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: KRichText(
                  message: widget.message,
                  attachments: widget.attachments,
                  enableMargin: false,
                ),
              ),
            ),
        ],
      ),
    );
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
    return DottedBorder(
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
                enableMargin: false,
              )
          ],
        ),
      ),
    );
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
  final PollCallback? callback;

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
              context
                  .read<KeylolApiClient>()
                  .pollVote(widget.poll.tid!, pollAnswers)
                  .then((value) => widget.callback?.call(context));
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
