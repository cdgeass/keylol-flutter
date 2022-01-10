import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AutoResizeWebView extends StatefulWidget {
  final String url;
  final EdgeInsets? padding;
  final double? height;

  const AutoResizeWebView(
      {Key? key, required this.url, this.padding, this.height})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutoResizeWebViewState();
}

class _AutoResizeWebViewState extends State<AutoResizeWebView>
    with AutomaticKeepAliveClientMixin {
  double? _height;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var url = widget.url;
    if (url.startsWith('https://store.steampowered.com/widget')) {
      _height = 73.0;
    } else if (url.startsWith('https://player.bilibili.com/player.html')) {
      _height = 200.0;
    } else if (url.startsWith('https://music.163.com/outchain/player')) {
      url = url.replaceAllMapped(RegExp(r'height=(\d+)'), (match) {
        return 'height=70';
      });
      _height = 70.0;
    }

    return Container(
      padding: widget.padding,
      height: _height ?? widget.height ?? 73.0,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(url)),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                transparentBackground: true, javaScriptEnabled: true)),
        onLoadStop: (controller, uri) async {
          if (_height != null) {
            return;
          }
          final scrollHeight = await controller.evaluateJavascript(
              source: 'document.body.scrollHeight');
          if (scrollHeight != null) {
            final height = scrollHeight.ceilToDouble();
            setState(() {
              _height = height;
            });
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.CANCEL;
        },
      ),
    );
  }
}
