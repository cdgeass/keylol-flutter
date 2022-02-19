import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/authentication/authentication.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

import '../../../components/thread_card.dart';
import '../models/index.dart';
import '../widgets/widgets.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IndexBloc(client: KeylolClient().dio)..add(IndexFetched()),
      child: BlocConsumer<IndexBloc, IndexState>(
        listener: (context, state) {},
        builder: (context, state) {
          late Widget body;

          switch (state.status) {
            case IndexStatus.success:
              final index = state.index!;

              final slideView = _buildSlidView(index);
              final tabBar = _buildTabBar(index);
              final tabBarView = _buildTabBarView(index);

              body = NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: IndexAppBar(
                        expandedHeight: 275.0,
                        slideView: slideView,
                        tabBar: tabBar,
                        topPadding: MediaQuery.of(context).padding.top,
                      ),
                    ),
                  ];
                },
                body: tabBarView,
              );
              break;
            default:
              body = Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            drawer: DrawerWidget(),
            body: RefreshIndicator(
              notificationPredicate: (notification) {
                if (notification is OverscrollNotification || Platform.isIOS) {
                  return notification.depth == 2;
                }
                return notification.depth == 0;
              },
              onRefresh: () async {
                context.read<IndexBloc>().add(IndexFetched());
              },
              child: body,
            ),
          );
        },
      ),
    );
  }

  // 轮播图
  Widget _buildSlidView(Index index) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 275.0,
        enableInfiniteScroll: true,
        viewportFraction: 1.0,
        autoPlay: true,
      ),
      items: index.slideViewItems
          .map((slideViewItem) => SlideViewItem(slideViewItem: slideViewItem))
          .toList(),
    );
  }

  // TabBar
  TabBar _buildTabBar(Index index) {
    final tabs = index.tabThreadsMap.keys
        .map((key) => Tab(child: Text(key.name)))
        .toList();

    if (_controller == null) {
      _controller = TabController(length: tabs.length, vsync: this);
    }

    return TabBar(
      controller: _controller,
      tabs: tabs,
      isScrollable: true,
    );
  }

  // TabBarView
  Widget _buildTabBarView(Index index) {
    final children = index.tabThreadsMap.keys.map((key) {
      final threads = index.tabThreadsMap[key]!;
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        children: threads.map((thread) => ThreadCard(thread: thread)).toList(),
      );
    }).toList();

    return TabBarView(
      controller: _controller,
      children: children,
    );
  }
}
