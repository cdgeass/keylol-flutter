import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/thread/bloc/thread_bloc.dart';
import 'package:keylol_flutter/app/thread/widgets/widgets.dart';
import 'package:keylol_flutter/components/avatar.dart';
import 'package:keylol_flutter/components/post_card.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/models/post.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ThreadList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThreadListState();
}

class _ThreadListState extends State<ThreadList> {
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
    return BlocBuilder<ThreadBloc, ThreadState>(
      builder: (context, state) {
        final authorIndex = 0;
        final threadIndex = authorIndex + state.threadWidgets.length;
        final threadActionsIndex = threadIndex + 1;
        final postsIndex = threadActionsIndex + state.posts.length - 1;

        final topPadding = MediaQuery.of(context).padding.top;

        return Scaffold(
          body: CustomScrollView(
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
                    if (index == authorIndex) {
                      // 帖子作者
                      return Material(
                        color: Theme.of(context).cardColor,
                        child: _buildFirstHeader(state.posts[0]),
                      );
                    } else if (index > authorIndex && index <= threadIndex) {
                      // 帖子
                      return Material(
                        color: Theme.of(context).cardColor,
                        child: state.threadWidgets[index - 1],
                      );
                    } else if (index <= threadActionsIndex) {
                      // 间隔
                      return Material(
                        color: Theme.of(context).cardColor,
                        elevation: 1.0,
                        child: SizedBox(
                          height: 16.0,
                        ),
                      );
                    } else if (index > threadActionsIndex &&
                        index < postsIndex) {
                      // 回复
                      return PostCard(
                        post: state.posts[index - threadActionsIndex + 1],
                        builder: (post) {
                          return KRichTextBuilder(post.message,
                                  attachments: post.attachments)
                              .build();
                        },
                      );
                    } else if (index == postsIndex) {
                      if (state.status == ThreadStatus.failure) {
                        // 异常
                        return Material(
                          color: Theme.of(context).cardColor,
                          elevation: 1.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(state.error ?? ''),
                          ),
                        );
                      } else {
                        // loading
                        return Padding(
                          padding: EdgeInsets.all(16.0),
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
                  },
                  childCount:
                      state.threadWidgets.length + 2 + state.posts.length,
                ),
              ),
            ],
          ),
        );
      },
    );
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
