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
    return Container(
      padding: widget.padding,
      height: _height ?? widget.height ?? 73.0,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                transparentBackground: true, javaScriptEnabled: true)),
        onLoadStop: (controller, uri) async {
          if (_height != null) {
            return;
          }
          if (uri
              .toString()
              .startsWith('https://store.steampowered.com/widget')) {
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
