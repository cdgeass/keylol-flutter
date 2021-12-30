import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String initialUrl;
  final WebviewCookieManager _cookieManager = WebviewCookieManager();

  WebViewPage({Key? key, required this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initialUrl.startsWith('https://keylol.com')) {
      final future = _loadCookies();
      return ThrowableFutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(),
            body: WebView(initialUrl: initialUrl),
          );
        },
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: initialUrl,
          navigationDelegate: (request) async {
            final url = request.url;

            if (await canLaunch((url))) {
              await launch(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }
  }

  Future _loadCookies() async {
    final cookies = await KeylolClient().getCookies();
    await _cookieManager.setCookies(cookies);
  }
}
