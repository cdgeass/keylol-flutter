import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/repository/fav_thread_repository.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../widgets/widgets.dart';

class ThreadPage extends StatelessWidget {
  final String tid;
  final String? pid;

  const ThreadPage({
    Key? key,
    required this.tid,
    this.pid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThreadBloc(
        client: context.read<KeylolApiClient>(),
        favThreadRepository: context.read<FavThreadRepository>(),
        tid: tid,
      )..add(ThreadReloaded()),
      child: ThreadPageView(),
    );
  }
}

class ThreadPageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThreadPageViewState();
}

class _ThreadPageViewState extends State<ThreadPageView> {
  final _controller = AutoScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final maxScroll = _controller.position.maxScrollExtent;
      final pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        context.read<ThreadBloc>().add(ThreadLoaded());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThreadBloc, ThreadState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status != ThreadStatus.success) {
          return Scaffold(
            appBar: AppBar(),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ThreadBloc>().add(ThreadReloaded());
              },
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final authorIndex = 0;
        final threadIndex = authorIndex + state.threadWidgets.length;
        final threadActionsIndex = threadIndex + 1;
        final postsIndex = threadActionsIndex + state.posts.length - 1;
        final topPadding = MediaQuery.of(context).padding.top;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(ReplyRoute(state.thread, null, () {}));
              }),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ThreadBloc>().add(ThreadReloaded());
            },
            child: CustomScrollView(
              controller: _controller,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ThreadAppBar(
                    thread: state.thread!,
                    textStyle: Theme.of(context).textTheme.headline6!,
                    width: MediaQuery.of(context).size.width,
                    topPadding: topPadding,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: _controller,
                        index: index,
                        child: _getListItem(
                          index,
                          authorIndex,
                          threadIndex,
                          threadActionsIndex,
                          postsIndex,
                          context,
                          state,
                        ),
                      );
                    },
                    childCount:
                        state.threadWidgets.length + 2 + state.posts.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getListItem(
    int index,
    int authorIndex,
    int threadIndex,
    int threadActionsIndex,
    int postsIndex,
    BuildContext context,
    ThreadState state,
  ) {
    if (index == authorIndex) {
      // 帖子作者
      return Material(
        color: Theme.of(context).cardColor,
        child: _buildFirstHeader(state.posts[0]),
      );
    } else if (index <= threadIndex) {
      // 帖子
      return Material(
        color: Theme.of(context).cardColor,
        child: state.threadWidgets[index - 1],
      );
    } else if (index == threadActionsIndex) {
      // 间隔
      return Material(
        color: Theme.of(context).cardColor,
        elevation: 1.0,
        child: SizedBox(
          height: 16.0,
        ),
      );
    } else if (index <= postsIndex) {
      // 回复
      return PostCard(
        post: state.posts[index - threadActionsIndex],
        builder: (post) {
          return KRichTextBuilder(post.message, attachments: post.attachments)
              .build();
        },
      );
    } else if (index > postsIndex) {
      if (state.status == ThreadStatus.failure) {
        // 异常
        return Card(
          margin: EdgeInsets.only(top: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Center(
            child: Text(state.error ?? ''),
          ),
        );
      } else {
        // loading
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Opacity(
              opacity: state.hasReachedMax ? 0.0 : 1.0,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
    }
    return Container();
  }

  Widget _buildFirstHeader(Post post) {
    return ListTile(
      leading: Avatar(
        uid: post.authorId,
        size: AvatarSize.middle,
        width: 40.0,
      ),
      title: Text(post.author),
      subtitle: Text(post.dateline),
    );
  }
}
