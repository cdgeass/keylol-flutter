import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/fav/bloc/fav_thread_bloc.dart';
import 'package:keylol_flutter/components/authentication_bloc_provider.dart';
import 'package:keylol_flutter/components/list_divider.dart';
import 'package:keylol_flutter/components/thread_item.dart';
import 'package:keylol_flutter/repository/repository.dart';

class FavThreadPage extends StatefulWidget {
  const FavThreadPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavThreadPageState();
}

class _FavThreadPageState extends State<FavThreadPage> {
  @override
  Widget build(context) {
    return AuthenticationBlocProvider(
      create: (_) =>
          FavThreadBloc(repository: context.read<FavThreadRepository>())
            ..add(FavThreadLoaded()),
      event: FavThreadReloaded(),
      child: BlocBuilder<FavThreadBloc, FavThreadState>(
        builder: (context, state) {
          late Widget body;

          switch (state.status) {
            case FavThreadStatus.success:
              body = ListView.separated(
                itemCount: state.favThreads.length,
                itemBuilder: (context, index) {
                  final favThread = state.favThreads[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(
                          int.parse(favThread.dateline + '000'))
                      .toLocal();
                  return ThreadItem(
                    thread: Thread.fromJson({
                      'tid': favThread.id,
                      'subject': favThread.title,
                      'dateline': '${date.year}-${date.month}-${date.day}',
                      'author': favThread.author
                    }),
                    wrapperBuilder: (content) {
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
                          color: Theme.of(context).colorScheme.error,
                          child: Padding(
                              padding: EdgeInsets.only(
                                  top: 8.0, right: 16.0, bottom: 8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '删除',
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return ListDivider(
                    isLast: index == state.favThreads.length - 1,
                  );
                },
              );
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
