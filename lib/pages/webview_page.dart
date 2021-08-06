import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
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
      return Scaffold(
          appBar: AppBar(),
          body: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: initialUrl,
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ));
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: initialUrl,
        ),
      );
    }
  }

  Future _loadCookies() async {
    final cookies = await Global.keylolClient.cj
        .loadForRequest(Uri.parse('https://keylol.com'));
    await _cookieManager.setCookies(cookies);
  }
}
