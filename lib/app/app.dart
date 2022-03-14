import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/notice/view/notice_page.dart';
import 'package:keylol_flutter/app/thread/view/view.dart';
import 'package:keylol_flutter/repository/fav_thread_repository.dart';
import 'package:keylol_flutter/theme/cubit/theme_cubit.dart';

import 'authentication/authentication.dart';
import 'fav/view/view.dart';
import 'forum/view/view.dart';
import 'guide/view/view.dart';
import 'index/index.dart';
import 'login/view/view.dart';

class KeylolApp extends StatelessWidget {
  final KeylolApiClient _client;

  const KeylolApp({
    Key? key,
    required KeylolApiClient client,
  })  : _client = client,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<KeylolApiClient>(
          create: (_) => _client,
        ),
        RepositoryProvider<FavThreadRepository>(
          create: (_) => FavThreadRepository(client: _client)..load(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (_) => AuthenticationBloc(client: _client)
              ..add(AuthenticationLoaded()),
            lazy: false,
          ),
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(),
          )
        ],
        child: KeylolAppView(),
      ),
    );
  }
}

class KeylolAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, Color>(
      builder: (context, color) {
        return MaterialApp(
          theme: ThemeData(colorSchemeSeed: color, useMaterial3: true),
          darkTheme: ThemeData.dark(),
          routes: {
            '/index': (context) => IndexPage(),
            '/guide': (context) => GuidePage(),
            '/forum': (context) => ForumIndexPage(),
            '/notice': (context) => NoticePage(),
            '/login': (context) => LoginPage(),
            '/thread': (context) {
              final arguments =
                  ModalRoute.of(context)!.settings.arguments as dynamic;
              return ThreadPage(
                tid: arguments['tid'],
                pid: arguments['pid'],
              );
            },
            '/favThread': (context) => FavThreadPage(),
            '/webView': (context) {
              final uri = ModalRoute.of(context)!.settings.arguments as String;
              return InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(uri)),
              );
            }
          },
          initialRoute: '/index',
        );
      },
    );
  }
}
