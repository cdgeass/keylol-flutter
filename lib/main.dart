import 'package:flutter/material.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/common/provider.dart';
import 'package:keylol_flutter/common/theme.dart';
import 'package:keylol_flutter/models/space.dart';
import 'package:keylol_flutter/pages/forum_index_page.dart';
import 'package:keylol_flutter/pages/forum_page.dart';
import 'package:keylol_flutter/pages/guide_page.dart';
import 'package:keylol_flutter/pages/index_page.dart';
import 'package:keylol_flutter/pages/login_page.dart';
import 'package:keylol_flutter/pages/note_list_page.dart';
import 'package:keylol_flutter/pages/profile_page.dart';
import 'package:keylol_flutter/pages/space_thread_page.dart';
import 'package:keylol_flutter/pages/thread_page.dart';
import 'package:keylol_flutter/pages/webview_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ChangeNotifierProvider(create: (context) => ProfileProvider()),
    ChangeNotifierProvider(create: (context) => NoticeProvider()),
    ChangeNotifierProvider(create: (context) => FavoriteThreadsProvider()),
  ], builder: (context, child) => KeylolApp()));
}

class KeylolApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _KeylolAppState();
}

class _KeylolAppState extends State<KeylolApp> {
  late Future<bool> _future;

  @override
  void initState() {
    super.initState();

    _future = init(context);
  }

  Future<bool> init(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme') ?? 0;
      Provider.of<ThemeProvider>(context, listen: false)
          .update(colors[themeIndex]);

      await KeylolClient()
          .init(context)
          .then((_) => KeylolClient().fetchProfile())
          .then((_) => KeylolClient().fetchAllFavoriteThreads());
    } catch (error) {
      print(error.toString());
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: Provider.of<ThemeProvider>(context).themeData,
        darkTheme: ThemeData.dark(),
        title: 'Keylol',
        routes: _routes(),
        home: FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return IndexPage();
              } else {
                return Container(
                    color: blue.primaryColor,
                    child: Center(
                      child: Image.asset('images/splash.png'),
                    ));
              }
            }));
  }
}

Map<String, WidgetBuilder> _routes() {
  return {
    "/login": (context) => LoginPage(),
    "/index": (context) => IndexPage(),
    "/guide": (context) => GuidePage(),
    "/forumIndex": (context) => ForumIndexPage(),
    "/forum": (context) {
      final fid = ModalRoute.of(context)?.settings.arguments as String;
      return ForumPage(fid: fid);
    },
    "/noteList": (context) => NoteListPage(),
    "/thread": (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      late String tid;
      String? pid;
      if (arguments is List) {
        tid = arguments[0];
        pid = arguments[1];
      } else {
        tid = arguments as String;
      }
      return ThreadPage(tid: tid, pid: pid);
    },
    "/profile": (context) {
      final uid = ModalRoute.of(context)?.settings.arguments as String;
      return ProfilePage(uid: uid);
    },
    "/space/thread": (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as List;
      return SpaceThreadPage(
        space: arguments[0],
        initialIndex: arguments[1],
      );
    },
    "/webview": (context) {
      var initialUrl = ModalRoute.of(context)?.settings.arguments as String;
      return WebViewPage(initialUrl: initialUrl);
    }
  };
}
