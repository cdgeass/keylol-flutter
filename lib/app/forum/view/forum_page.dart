import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/forum_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/thread_list_bloc.dart';
import 'package:keylol_flutter/app/forum/widgets/widgets.dart';

class ForumPage extends StatelessWidget {
  final String fid;

  const ForumPage({Key? key, required this.fid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.read<KeylolApiClient>();
    return BlocProvider(
      create: (_) =>
          ForumBloc(client: client, fid: fid)..add(ForumDetailFetched()),
      child: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          switch (state.status) {
            case ForumStatus.failure:
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text('出错啦!!!')),
              );
            case ForumStatus.success:
              final forum = state.forum!;
              final types = state.types;

              return DefaultTabController(
                length: types.length + 1,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(forum.name!),
                    centerTitle: true,
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
                          client: client,
                          fid: fid,
                        )..add(ThreadListReloaded()),
                        child: ForumThreadList(),
                      ),
                      for (final type in types)
                        BlocProvider(
                          create: (_) => ThreadListBloc(
                              client: client, fid: fid, typeId: type.id)
                            ..add(ThreadListReloaded()),
                          child: ForumThreadList(),
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
