import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/pages/forum_index_page.dart';
import 'package:keylol_flutter/pages/forum_page.dart';
import 'package:keylol_flutter/pages/index_page.dart';
import 'package:keylol_flutter/pages/login_page.dart';
import 'package:keylol_flutter/pages/note_list_page.dart';
import 'package:keylol_flutter/pages/profile_page.dart';
import 'package:keylol_flutter/pages/thread_page.dart';
import 'package:keylol_flutter/pages/webview_page.dart';

import 'common/styling.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KeylolClient().init();

  KeylolClient().fetchProfile();

  runApp(KeylolApp());
}

class KeylolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keylol',
      theme: ThemeData(
          primaryColor: Colors.lightBlue,
          backgroundColor: Color(0xFFFAFAFA),
          textTheme: AppTheme.textTheme),
      darkTheme: ThemeData.dark(),
      initialRoute: "/index",
      routes: _routes(),
    );
  }
}

Map<String, WidgetBuilder> _routes() {
  return {
    "/login": (context) => LoginPage(),
    "/index": (context) => IndexPage(),
    "/forumIndex": (context) => ForumIndexPage(),
    "/forum": (context) {
      final fid = ModalRoute.of(context)?.settings.arguments as String;
      return ForumPage(fid: fid);
    },
    "/noteList": (context) => NoteListPage(),
    "/thread": (context) {
      final tid = ModalRoute.of(context)?.settings.arguments as String;
      return ThreadPage(tid: tid);
    },
    "/profile": (context) {
      final uid = ModalRoute.of(context)?.settings.arguments as String;
      return ProfilePage(uid: uid);
    },
    "/webview": (context) {
      var initialUrl = ModalRoute.of(context)?.settings.arguments as String;
      return WebViewPage(initialUrl: initialUrl);
    }
  };
}
