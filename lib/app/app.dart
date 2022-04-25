import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_count_bloc.dart';
import 'package:keylol_flutter/app/notice/view/notice_page.dart';
import 'package:keylol_flutter/app/space/view/space_page.dart';
import 'package:keylol_flutter/app/thread/view/view.dart';
import 'package:keylol_flutter/repository/repository.dart';
import 'package:keylol_flutter/theme/cubit/theme_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'authentication/authentication.dart';
import 'fav/view/view.dart';
import 'forum/view/view.dart';
import 'guide/view/view.dart';
import 'index/index.dart';
import 'login/view/view.dart';

class KeylolApp extends StatelessWidget {
  final KeylolApiClient _client;
  final ProfileRepository _profileRepository;
  final NoticeRepository _noticeRepository;

  const KeylolApp({
    Key? key,
    required KeylolApiClient client,
    required ProfileRepository profileRepository,
    required NoticeRepository noticeRepository,
  })  : _client = client,
        _profileRepository = profileRepository,
        _noticeRepository = noticeRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _client),
        RepositoryProvider.value(value: _profileRepository),
        RepositoryProvider.value(value: _noticeRepository),
        RepositoryProvider<FavThreadRepository>(
          create: (_) => FavThreadRepository(client: _client)..load(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(),
          ),
          BlocProvider<AuthenticationBloc>(
            create: (_) => AuthenticationBloc(client: _client)
              ..add(AuthenticationLoaded()),
            lazy: false,
          ),
          BlocProvider<NoticeCountBloc>(
            create: (_) => NoticeCountBloc(_noticeRepository),
          ),
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
            '/notice': (context) {
              context
                  .read<NoticeCountBloc>()
                  .add(NoticeCountUpdated(EMPTY_NOTICE));
              return NoticePage();
            },
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
            '/space': (context) {
              final uid = ModalRoute.of(context)!.settings.arguments as String;
              return SpacePage(uid: uid);
            },
            '/webView': (context) {
              final uri = ModalRoute.of(context)!.settings.arguments as String;
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_outlined),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text('在浏览器中打开'),
                            onTap: () {
                              launch(uri);
                            },
                          )
                        ];
                      },
                    )
                  ],
                ),
                body: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(uri)),
                ),
              );
            }
          },
          initialRoute: '/index',
        );
      },
    );
  }
}
