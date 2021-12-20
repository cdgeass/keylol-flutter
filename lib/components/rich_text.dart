import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:keylol_flutter/models/view_thread.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

class KRichText extends StatefulWidget {
  final String message;

  const KRichText({Key? key, required this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KRichTextState();
}

class _KRichTextState extends State<KRichText> {
  List<VideoPlayerController> _videoPlayerControllers = [];
  LinkedHashMap<String, double> _iframeHeights = LinkedHashMap();

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

    // 折叠内容
    final collapseReg = RegExp(r'\[collapse(=?)([^\]]*)]');
    if (collapseReg.hasMatch(message)) {
      final collapseMatches = collapseReg.allMatches(message);
      for (var collapseMatch in collapseMatches) {
        final title = collapseMatch.group(2) ?? "";
        if (title != "") {
          message = message.replaceFirst(
              '[collapse=' + title + ']', '<collapse title="' + title + '">');
        } else {
          message = message.replaceFirst(
              '[collapse]', '<collapse title="' + title + '">');
        }
      }
      message = message.replaceAll('[/collapse]', '</collapse>');
    }

    // 折叠内容
    final spoilReg = RegExp(r'\[spoil(=?)([^\]]*)]');
    if (spoilReg.hasMatch(message)) {
      final spoilMatches = spoilReg.allMatches(message);
      for (var spoilMatch in spoilMatches) {
        final title = spoilMatch.group(2) ?? "";
        if (title != "") {
          message = message.replaceFirst(
              '[spoil=' + title + ']', '<spoil title="' + title + '">');
        } else {
          message =
              message.replaceFirst('[spoil]', '<spoil title="' + title + '">');
        }
      }
      message = message.replaceAll('[/spoil]', '</spoil>');
    }

    message = HtmlUnescape().convert(message);

    var index = 0;
    _iframeHeights.forEach((key, value) {
      message = message.replaceAll(
          'src="$key"', 'id="iframe-$index" src="$key" height="$value"');
    });

    return message
        .replaceAll('[media]', '<video src="')
        .replaceAll('[/media]', '"></video>');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final style = {
      '.reply_wrap': Style(padding: EdgeInsets.all(16.0)),
      'iframe': Style(height: 72.0)
    };
    var index = 0;
    _iframeHeights.forEach((key, value) {
      style['#iframe-$index'] = Style(height: value);
    });

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
              late final webview.WebViewController webViewController;
              return SizedBox(
                  height: _iframeHeights[src] ?? 72.0,
                  child: webview.WebView(
                    initialUrl: src,
                    javascriptMode: webview.JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onPageFinished: (url) async {
                      if (_iframeHeights.containsKey(url)) {
                        return;
                      }
                      final pxHeight = double.parse(
                          await webViewController.runJavascriptReturningResult(
                              'document.body.scrollHeight;'));
                      final height = (pxHeight / (mediaQuery.devicePixelRatio))
                          .ceilToDouble();
                      setState(() {
                        _iframeHeights[url] = height;
                      });
                    },
                    navigationDelegate: (request) {
                      return webview.NavigationDecision.prevent;
                    },
                  ));
            }
            return Container();
          }
        },
        style: style);
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
                  color: Colors.white,
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
