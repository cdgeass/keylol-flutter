import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/fav/bloc/fav_thread_bloc.dart';
import 'package:keylol_flutter/components/thread_card.dart';
import 'package:keylol_flutter/repository/repository.dart';

class FavThreadPage extends StatelessWidget {
  @override
  Widget build(context) {
    return BlocProvider(
      create: (_) =>
          FavThreadBloc(repository: context.read<FavThreadRepository>())
            ..add(FavThreadLoaded()),
      child: BlocBuilder<FavThreadBloc, FavThreadState>(
        builder: (context, state) {
          late Widget body;

          switch (state.status) {
            case FavThreadStatus.success:
              body = ListView.builder(
                  itemCount: state.favThreads.length,
                  itemBuilder: (context, index) {
                    final favThread = state.favThreads[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                            int.parse(favThread.dateline + '000'))
                        .toLocal();
                    return ThreadCard(
                      thread: Thread.fromJson({
                        'tid': favThread.id,
                        'subject': favThread.title,
                        'dateline': '${date.year}-${date.month}-${date.day}',
                        'author': favThread.author
                      }),
                      builder: (content) {
                        return Dismissible(
                          key: Key(favThread.favId),
                          onDismissed: (_) {
                            context
                                .read<FavThreadBloc>()
                                .add(FavThreadDelete(favThread.favId));
                          },
                          child: content,
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, right: 16.0, bottom: 8.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        '删除',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                    );
                  });
              break;
            default:
              body = Center(child: CircularProgressIndicator());
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('收藏'),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<FavThreadBloc>().add(FavThreadReloaded());
              },
              child: body,
            ),
          );
        },
      ),
    );
  }
}
