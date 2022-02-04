import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/models/post.dart';
import 'package:keylol_flutter/models/view_thread.dart';

part './thread_event.dart';

part './thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  final _logger = Log();
  final Dio client;
  final String tid;

  ThreadBloc({
    required this.client,
    required this.tid,
  }) : super(ThreadState(status: ThreadStatus.initial)) {
    on<ThreadReloaded>(_onThreadReloaded);
    on<ThreadLoaded>(_onThreadLoaded);
  }

  Future<void> _onThreadReloaded(
    ThreadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final viewThread = await _fetchThread(1);

      final thread = viewThread.thread;
      final posts = viewThread.postList;
      final hasReachedMax = posts.length == thread.replies + 1;

      final threadPost = posts[0];
      final threadWidgets = KRichTextBuilder(threadPost.message,
              attachments: threadPost.attachments, poll: viewThread.specialPoll)
          .splitBuild();

      emit(state.copyWith(
        status: ThreadStatus.success,
        thread: thread,
        threadWidgets: threadWidgets,
        page: 1,
        posts: posts,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('获取帖子详情错误', error);
      emit(state.copyWith(
        status: ThreadStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onThreadLoaded(
    ThreadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final page = state.page + 1;

      final viewThread = await _fetchThread(page);
      final posts = viewThread.postList;

      if (posts.isEmpty) {
        emit(state.copyWith(
          status: ThreadStatus.success,
          hasReachedMax: true,
        ));
      } else {
        final finalPosts = state.posts;
        posts.forEach((post) {
          if (!finalPosts.any((p) => p.pid == post.pid)) {
            finalPosts.add(post);
          }
        });
        final hasReachedMax =
            finalPosts.length == viewThread.thread.replies + 1;
        emit(state.copyWith(
          status: ThreadStatus.success,
          page: page,
          posts: finalPosts,
          hasReachedMax: hasReachedMax,
        ));
      }
    } catch (error) {
      _logger.e('加载帖子详情错误', error);
      emit(state.copyWith(
        status: ThreadStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<ViewThread> _fetchThread(int page) async {
    var res = await client.get("/api/mobile/index.php", queryParameters: {
      'version': null,
      'module': 'viewthread',
      'tid': tid,
      'cp': 'all',
      'page': page
    });

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return ViewThread.fromJson(res.data['Variables']);
  }
}
