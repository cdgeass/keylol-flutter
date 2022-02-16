import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/notice/view/notice_page.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

import 'authentication/authentication.dart';
import 'forum/view/view.dart';
import 'guide/view/view.dart';
import 'index/index.dart';
import 'login/view/view.dart';

class KeylolApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthenticationBloc(client: KeylolClient().dio)
        ..add(AuthenticationLoaded()),
      lazy: false,
      child: MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        routes: {
          '/index': (context) => IndexPage(),
          '/guide': (context) => GuidePage(),
          '/forum': (context) => ForumIndexPage(),
          '/notice': (context) => NoticePage(),
          '/login': (context) => LoginPage(),
        },
        initialRoute: '/index',
      ),
    );
  }
}
