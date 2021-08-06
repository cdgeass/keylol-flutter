import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/global.dart';
import 'package:keylol_flutter/pages/forum_index_page.dart';
import 'package:keylol_flutter/pages/forum_page.dart';
import 'package:keylol_flutter/pages/index_page.dart';
import 'package:keylol_flutter/pages/login_page.dart';
import 'package:keylol_flutter/pages/thread_page.dart';
import 'package:keylol_flutter/pages/webview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Global.init();
  runApp(KeylolApp());
}

class KeylolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keylol',
      theme: ThemeData.light(),
      initialRoute: "/index",
      routes: {
        "/login": (context) => LoginPage(),
        "/index": (context) => IndexPage(),
        "/forumIndex": (context) => ForumIndexPage(),
        "/forum": (context) {
          var fid = ModalRoute.of(context)?.settings.arguments as String;
          return ForumPage(fid: fid);
        },
        "/thread": (context) {
          var tid = ModalRoute.of(context)?.settings.arguments as String;
          return ThreadPage(tid: tid);
        },
        "/webview": (context) {
          var initialUrl = ModalRoute.of(context)?.settings.arguments as String;
          return WebViewPage(initialUrl: initialUrl);
        }
      },
    );
  }
}
