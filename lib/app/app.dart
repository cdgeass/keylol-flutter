import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/fav/fav_thread_page.dart';
import 'package:keylol_flutter/app/history/history_page.dart';
import 'package:keylol_flutter/app/home/home_page.dart';
import 'package:keylol_flutter/app/login/login_page.dart';
import 'package:keylol_flutter/app/space/space_list_page.dart';
import 'package:keylol_flutter/app/space/space_page.dart';
import 'package:keylol_flutter/app/thread/thread_page.dart';
import 'package:keylol_flutter/components/custom_webview.dart';
import 'package:keylol_flutter/repository/repository.dart';
import 'package:keylol_flutter/settings/settings.dart';

import 'authentication/authentication.dart';
import 'forum/view/view.dart';

class KeylolApp extends StatelessWidget {
  final KeylolApiClient _client;
  final SettingsRepository _settingsRepository;
  final AuthenticationRepository _authenticationRepository;
  final HistoryRepository _historyRepository;

  const KeylolApp({
    Key? key,
    required KeylolApiClient client,
    required SettingsRepository settingsRepository,
    required AuthenticationRepository authenticationRepository,
    required HistoryRepository historyRepository,
  })  : _client = client,
        _settingsRepository = settingsRepository,
        _authenticationRepository = authenticationRepository,
        _historyRepository = historyRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _client),
        RepositoryProvider.value(value: _settingsRepository),
        RepositoryProvider.value(value: _authenticationRepository),
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
          BlocProvider<AuthenticationBloc>(
            create: (_) => AuthenticationBloc(
                authenticationRepository: _authenticationRepository),
            lazy: false,
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
        return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null) {
            // On Android S+ devices, use the provided dynamic color scheme.
            // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
            lightColorScheme = lightDynamic.harmonized();
            // (Optional) Customize the scheme as desired. For example, one might
            // want to use a brand color to override the dynamic [ColorScheme.secondary].
            lightColorScheme = lightColorScheme.copyWith(secondary: color);
            // (Optional) If applicable, harmonize custom colors.
            // lightCustomColors = lightCustomColors.harmonized(lightColorScheme);

            // Repeat for the dark color scheme.
            darkColorScheme = darkDynamic.harmonized();
            darkColorScheme = darkColorScheme.copyWith(secondary: color);
            // darkCustomColors = darkCustomColors.harmonized(darkColorScheme);

            // _isDemoUsingDynamicColors = true; // ignore, only for demo purposes
          } else {
            // Otherwise, use fallback schemes.
            lightColorScheme = ColorScheme.fromSeed(
              seedColor: color,
            );
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: color,
              brightness: Brightness.dark,
            );
          }

          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
              tabBarTheme: TabBarTheme(
                labelColor: lightColorScheme.onSurface,
                labelStyle: Theme.of(context).textTheme.titleSmall,
                unselectedLabelColor: lightColorScheme.onSurfaceVariant,
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: lightColorScheme.primary,
                  ),
                ),
              ),
              // extensions: [lightCustomColors],
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              tabBarTheme: TabBarTheme(
                labelColor: darkColorScheme.onSurface,
                labelStyle: Theme.of(context).textTheme.titleSmall,
                unselectedLabelColor: darkColorScheme.onSurfaceVariant,
                unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: darkColorScheme.primary,
                  ),
                ),
              ),
              // extensions: [darkCustomColors],
            ),
            initialRoute: '/home',
            routes: {
              '/home': (context) => HomePage(),
              '/fav': (context) => FavThreadPage(),
              '/history': (context) => HistoryPage(),
              '/forum': (context) {
                final fid =
                    ModalRoute.of(context)!.settings.arguments as String;
                return ForumPage(fid: fid);
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
          );
        });
      },
    );
  }
}
