import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/guide/bloc/guide_bloc.dart';
import 'package:keylol_flutter/app/guide/widgets/widgets.dart';
import 'package:keylol_flutter/app/notice/widgets/widgets.dart';

class GuidePage extends StatelessWidget {
  final _tabs = [
    Tab(text: '最新热门'),
    Tab(text: '最新精华'),
    Tab(text: '最新回复'),
    Tab(text: '最新发表'),
    Tab(text: '抢沙发')
  ];

  @override
  Widget build(BuildContext context) {
    final client = context.read<KeylolApiClient>();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: NoticeLeading(),
          title: Text('导读'),
          centerTitle: true,
          bottom: TabBar(
            tabs: _tabs,
            isScrollable: true,
          ),
        ),
        drawer: DrawerWidget(),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) =>
                  GuideBloc(client: client, type: 'hot')..add(GuideReloaded()),
              child: GuideList(),
            ),
            BlocProvider(
              create: (_) => GuideBloc(client: client, type: 'digest')
                ..add(GuideReloaded()),
              child: GuideList(),
            ),
            BlocProvider(
              create: (_) =>
                  GuideBloc(client: client, type: 'new')..add(GuideReloaded()),
              child: GuideList(),
            ),
            BlocProvider(
              create: (_) => GuideBloc(client: client, type: 'newthread')
                ..add(GuideReloaded()),
              child: GuideList(),
            ),
            BlocProvider(
              create: (_) =>
                  GuideBloc(client: client, type: 'sofa')..add(GuideReloaded()),
              child: GuideList(),
            ),
          ],
        ),
      ),
    );
  }
}
