import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

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
              body: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
              ));
        },
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = (await controller.getUrl()).toString();

            if (await canLaunch((url))) {
              await launch(url);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
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
