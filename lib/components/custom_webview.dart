import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/common/url_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomWebView extends StatelessWidget {
  final String _uri;
  InAppWebViewController? _controller;

  CustomWebView({
    Key? key,
    required String uri,
  })  : _uri = uri,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _resolveUrl(context, this._uri, true);

    return WillPopScope(
      onWillPop: () async {
        if (_controller != null) {
          if (await _controller!.canGoBack()) {
            await _controller!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert_outlined),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('在浏览器中打开'),
                    onTap: () async {
                      if (await canLaunchUrlString(_uri)) {
                        launchUrlString(_uri);
                      }
                    },
                  )
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _setCookie(context, _uri),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return InAppWebView(
                initialUrlRequest: new URLRequest(url: Uri.parse(_uri)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                  ),
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url?.toString();
                  if (url == null) {
                    return null;
                  }
                  if (_resolveUrl(context, url, false)) {
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  bool _resolveUrl(BuildContext context, String url, bool replace) {
    final resolveResult = UrlUtils.resolveUrl(url);
    if (resolveResult.isNotEmpty) {
      final router = resolveResult['router'];
      final parameter = resolveResult['arguments'];
      if (replace) {
        Navigator.of(context)
            .pushReplacementNamed(router, arguments: parameter);
      } else {
        Navigator.of(context).pushNamed(router, arguments: parameter);
      }
      return true;
    }
    return false;
  }

  // 如果是其乐url先设置 cookie
  Future<void> _setCookie(BuildContext context, String url) async {
    final uri = Uri.parse('https://keylol.com');
    final cm = CookieManager.instance();

    final client = context.read<KeylolApiClient>();
    final cookies = await client.getCookies();
    for (final cookie in cookies) {
      await cm.setCookie(
          url: uri,
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          expiresDate: cookie.expires?.millisecondsSinceEpoch,
          isSecure: cookie.secure);
    }
  }
}
