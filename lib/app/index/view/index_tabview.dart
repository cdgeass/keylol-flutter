import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/index/bloc/index_bloc.dart';
import 'package:keylol_flutter/components/thread_card.dart';

class IndexTabView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexTabViewState();
}

class _IndexTabViewState extends State<IndexTabView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndexBloc, IndexState>(
      builder: (context, state) {
        switch (state.status) {
          case IndexStatus.failure:
            return Center(child: Text('出错啦!!!'));
          case IndexStatus.success:
            final index = state.index!;
            // tabBar
            final tabs = index.tabThreadsMap.keys
                .map((key) => Tab(child: Text(key.name)))
                .toList();
            // tabView
            final tabChildren = index.tabThreadsMap.keys.map((key) {
              final threads = index.tabThreadsMap[key]!;
              return ListView.builder(
                padding: EdgeInsets.zero,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemCount: threads.length,
                itemBuilder: (context, index) {
                  return ThreadCard(thread: threads[index]);
                },
              );
            }).toList();

            return DefaultTabController(
                length: tabs.length,
                child: Column(children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).primaryColor,
                    child: TabBar(
                      tabs: tabs,
                      isScrollable: true,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: tabChildren,
                    ),
                  )
                ]));
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
