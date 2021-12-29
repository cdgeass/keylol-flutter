import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AutoResizeWebView extends StatefulWidget {
  final String url;

  const AutoResizeWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutoResizeWebViewState();
}

class _AutoResizeWebViewState extends State<AutoResizeWebView> {
  double? _height;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: _height ?? 72.0,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                transparentBackground: true, javaScriptEnabled: false)),
        onLoadStop: (controller, uri) async {
          if (uri.toString().startsWith('https://steampowerd.com/widget')) {
            return;
          }
          final scrollHeight = await controller.evaluateJavascript(
              source: 'document.body.scrollHeight');
          if (scrollHeight != null) {
            final height = double.parse(scrollHeight).ceilToDouble();
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
