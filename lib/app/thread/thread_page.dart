import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/repository/fav_thread_repository.dart';
import 'package:keylol_flutter/repository/history_repository.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'widgets/widgets.dart';

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
      )..add(ThreadReloaded(pid: pid)),
      child: ThreadPageView(tid: tid),
    );
  }
}

class ThreadPageView extends StatefulWidget {
  final String tid;

  const ThreadPageView({Key? key, required this.tid}) : super(key: key);

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
        if (state.status == ThreadStatus.initial || state.thread == null) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                PopupMenuButton(
                  icon: Icon(Icons.more_vert_outlined),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('在浏览器中打开'),
                        onTap: () {
                          launchUrlString(
                            'https://keylol.com/t${widget.tid}-1-1',
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      )
                    ];
                  },
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ThreadBloc>().add(ThreadReloaded());
              },
              child: state.error == null
                  ? Center(child: CircularProgressIndicator())
                  : Card(
                      margin: EdgeInsets.only(top: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(state.error ?? ''),
                        ),
                      ),
                    ),
            ),
          );
        }

        // 跳转指定回复
        if (state.scrollTo != null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollTo(state.scrollTo!);
          });
        }

        // 记录浏览历史
        context.read<HistoryRepository>().insertHistory(state.thread!);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  ReplyRoute(context.read<ThreadBloc>(), state.thread, null),
                );
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
                    textStyle: Theme.of(context).textTheme.headlineMedium!,
                    width: MediaQuery.of(context).size.width,
                    appBarHeight: 86.1,
                    favId: state.favId,
                    topPadding: MediaQuery.of(context).padding.top,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Material(
                    color: Theme.of(context).cardColor,
                    child: _buildFirstHeader(state.posts[0]),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // 帖子
                      return Material(
                        color: Theme.of(context).cardColor,
                        child: state.threadWidgets[index],
                      );
                    },
                    childCount: state.threadWidgets.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Material(
                    color: Theme.of(context).cardColor,
                    elevation: 1.0,
                    child: SizedBox(
                      height: 16.0,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = state.posts[index + 1];
                      return AutoScrollTag(
                        key: Key(post.pid),
                        controller: _controller,
                        index: index,
                        child: PostItem(
                          post: post,
                          builder: (post) {
                            return KRichTextBuilder(
                              post.message,
                              attachments: post.attachments,
                              scrollTo: _scrollTo,
                            ).build();
                          },
                        ),
                      );
                    },
                    childCount: state.posts.length - 1,
                  ),
                ),
                if (state.status == ThreadStatus.failure)
                  SliverToBoxAdapter(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                        child: Center(
                          child: Text(state.error ?? ''),
                        ),
                      ),
                    ),
                  ),
                if (state.status != ThreadStatus.failure)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Opacity(
                          opacity: state.hasReachedMax ? 0.0 : 1.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirstHeader(Post post) {
    return ListTile(
      leading: Avatar(
        uid: post.authorId,
        username: post.author,
        width: 40.0,
        height: 40.0,
      ),
      title: Text(post.author),
      subtitle: Text(post.dateline),
    );
  }

  void _scrollTo(String pid) {
    final state = context.read<ThreadBloc>().state;
    final posts = state.posts;
    int index = 0;
    for (final post in posts) {
      if (post.pid == pid) {
        break;
      }
      index++;
    }

    _controller.scrollToIndex(index - 1);
  }
}
