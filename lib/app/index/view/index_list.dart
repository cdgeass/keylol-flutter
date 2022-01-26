import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/app/index/models/models.dart';
import 'package:keylol_flutter/app/index/widgets/widgets.dart';
import 'package:keylol_flutter/components/sliver_tab_bar_delegate.dart';
import 'package:keylol_flutter/components/thread_card.dart';

class IndexList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexListState();
}

class _IndexListState extends State<IndexList> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndexBloc, IndexState>(
      builder: (context, state) {
        switch (state.status) {
          case IndexStatus.failure:
            return Center(child: Text('出错啦!!!'));
          case IndexStatus.success:
            final index = state.index!;

            final slideView = _buildSlidView(index);
            final tabBar = _buildTabBar(index);
            final tabBarView = _buildTabBarView(index);

            return RefreshIndicator(
              notificationPredicate: (notification) {
                if (notification is OverscrollNotification || Platform.isIOS) {
                  return notification.depth == 2;
                }
                return notification.depth == 0;
              },
              onRefresh: () async {
                context.read<IndexBloc>().add(IndexFetched());
              },
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: IndexAppBar(
                      expandedHeight: 275.0,
                      slideView: slideView,
                      tabBar: tabBar,
                    ),
                  ),
                  SliverFillRemaining(
                    child: tabBarView,
                  )
                ],
              ),
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
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

    _controller = TabController(length: tabs.length, vsync: this);

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
