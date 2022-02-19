import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/components/rich_text.dart';
import 'package:keylol_flutter/repository/fav_thread_repository.dart';

part './thread_event.dart';

part './thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  final _logger = Log();
  final KeylolApiClient _client;
  final FavThreadRepository _favThreadRepository;
  final String _tid;

  ThreadBloc({
    required KeylolApiClient client,
    required FavThreadRepository favThreadRepository,
    required String tid,
  })  : _client = client,
        _favThreadRepository = favThreadRepository,
        _tid = tid,
        super(ThreadState(status: ThreadStatus.initial)) {
    on<ThreadReloaded>(_onThreadReloaded);
    on<ThreadLoaded>(_onThreadLoaded);
    on<ThreadFavored>(_onFavored);
    on<ThreadUnfavored>(_onUnfavored);
  }

  Future<void> _onThreadReloaded(
    ThreadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      final viewThread = await _client.fetchThread(tid: _tid);

      final thread = viewThread.thread;
      final posts = viewThread.postList;
      final hasReachedMax = posts.length == thread.replies + 1;

      final threadPost = posts[0];
      final threadWidgets = KRichTextBuilder(threadPost.message,
              attachments: threadPost.attachments, poll: viewThread.specialPoll)
          .splitBuild();

      final favId = _favThreadRepository.fetchFavId(tid: _tid);

      emit(state.copyWith(
        status: ThreadStatus.success,
        thread: thread,
        threadWidgets: threadWidgets,
        page: 1,
        posts: posts,
        hasReachedMax: hasReachedMax,
        favId: favId,
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

      final viewThread = await _client.fetchThread(tid: _tid, page: page);
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
          favId: state.favId,
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

  Future<void> _onFavored(
    ThreadFavored event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      if (state.favId != null || state.thread == null) {
        return;
      }
      _favThreadRepository.add(
          thread: state.thread!, description: event.description);
      emit(state.copyWith(
        favId: _favThreadRepository.fetchFavId(tid: state.thread!.tid),
      ));
    } catch (error) {
      _logger.e('收藏帖子错误', error);
    }
  }

  Future<void> _onUnfavored(
    ThreadEvent event,
    Emitter<ThreadState> emit,
  ) async {
    try {
      if (state.favId == null) {
        return;
      }
      _favThreadRepository.delete(favId: state.favId!);
      emit(state.copyWith(
        favId: null,
      ));
    } catch (error) {
      _logger.e('收藏帖子错误', error);
    }
  }
}
