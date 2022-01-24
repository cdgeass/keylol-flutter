import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/forum_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/thread_list_bloc.dart';
import 'package:keylol_flutter/app/forum/widgets/forum_thread_list.dart';
import 'package:keylol_flutter/common/keylol_client.dart';

class ForumPage extends StatelessWidget {
  final String fid;

  const ForumPage({Key? key, required this.fid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForumBloc(client: KeylolClient().dio, fid: fid)
        ..add(ForumDetailFetched()),
      child: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          switch (state.status) {
            case ForumStatus.failure:
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text('出错啦!!!')),
              );
            case ForumStatus.success:
              final types = state.types;

              return DefaultTabController(
                length: types.length + 1,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(child: Text('全部')),
                        for (final type in types) Tab(child: Text(type.name)),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      BlocProvider(
                        create: (_) => ThreadListBloc(
                          client: KeylolClient().dio,
                          fid: fid,
                        )..add(ThreadListReloaded()),
                        lazy: true,
                        child: DefaultForumThreadList(),
                      ),
                      for (final type in types)
                        BlocProvider(
                          create: (_) => ThreadListBloc(
                            client: KeylolClient().dio,
                            fid: fid,
                            typeId: type.id
                          )..add(ThreadListReloaded()),
                          lazy: true,
                          child: TypedForumThreadList(),
                        )
                    ],
                  ),
                ),
              );
            default:
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()),
              );
          }
        },
      ),
    );
  }
}
