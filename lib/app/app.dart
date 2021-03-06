import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/history/view/view.dart';
import 'package:keylol_flutter/app/notice/bloc/notice_count_bloc.dart';
import 'package:keylol_flutter/app/notice/view/notice_page.dart';
import 'package:keylol_flutter/app/space/view/space_list_page.dart';
import 'package:keylol_flutter/app/space/view/space_page.dart';
import 'package:keylol_flutter/app/thread/view/view.dart';
import 'package:keylol_flutter/components/custom_webview.dart';
import 'package:keylol_flutter/repository/repository.dart';
import 'package:keylol_flutter/settings/settings.dart';

import 'authentication/authentication.dart';
import 'fav/view/view.dart';
import 'forum/view/view.dart';
import 'guide/view/view.dart';
import 'index/index.dart';
import 'login/view/view.dart';

class KeylolApp extends StatelessWidget {
  final KeylolApiClient _client;
  final SettingsRepository _settingsRepository;
  final ProfileRepository _profileRepository;
  final NoticeRepository _noticeRepository;
  final HistoryRepository _historyRepository;

  const KeylolApp({
    Key? key,
    required KeylolApiClient client,
    required SettingsRepository settingsRepository,
    required ProfileRepository profileRepository,
    required NoticeRepository noticeRepository,
    required HistoryRepository historyRepository,
  })  : _client = client,
        _settingsRepository = settingsRepository,
        _profileRepository = profileRepository,
        _noticeRepository = noticeRepository,
        _historyRepository = historyRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _client),
        RepositoryProvider.value(value: _settingsRepository),
        RepositoryProvider.value(value: _profileRepository),
        RepositoryProvider.value(value: _noticeRepository),
        RepositoryProvider.value(value: _historyRepository),
        RepositoryProvider<FavThreadRepository>(
          create: (_) => FavThreadRepository(client: _client)..load(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(settingsRepository: _settingsRepository),
            lazy: false,
          ),
          BlocProvider<MenuCubit>(
            create: (_) => MenuCubit(settingsRepository: _settingsRepository),
            lazy: false,
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
    return BlocBuilder<MenuCubit, List<String>>(
      builder: (context, menus) {
        return BlocBuilder<ThemeCubit, Color>(
          builder: (context, color) {
            return MaterialApp(
              theme: ThemeData(colorSchemeSeed: color),
              darkTheme: ThemeData.dark(),
              routes: {
                '/index': (context) => IndexPage(),
                '/guide': (context) => GuidePage(),
                '/forumIndex': (context) => ForumIndexPage(),
                '/forum': (context) {
                  final fid = ModalRoute.of(context)!.settings.arguments as String;
                  return ForumPage(fid: fid);
                },
                '/notice': (context) {
                  context
                      .read<NoticeCountBloc>()
                      .add(NoticeCountUpdated(EMPTY_NOTICE));
                  return NoticePage();
                },
                '/history': (context) => HistoryPage(),
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
                  final uid =
                      ModalRoute.of(context)!.settings.arguments as String;
                  return SpacePage(uid: uid);
                },
                '/space/friend': (context) {
                  final uid =
                      ModalRoute.of(context)!.settings.arguments as String;
                  return SpaceListPage(uid: uid, initialIndex: 0);
                },
                '/space/thread': (context) {
                  final uid =
                      ModalRoute.of(context)!.settings.arguments as String;
                  return SpaceListPage(uid: uid, initialIndex: 1);
                },
                '/space/reply': (context) {
                  final uid =
                      ModalRoute.of(context)!.settings.arguments as String;
                  return SpaceListPage(uid: uid, initialIndex: 2);
                },
                '/webView': (context) {
                  final uri =
                      ModalRoute.of(context)!.settings.arguments as String;
                  return CustomWebView(uri: uri);
                }
              },
              initialRoute: '/${menus[0]}',
            );
          },
        );
      },
    );
  }
}
