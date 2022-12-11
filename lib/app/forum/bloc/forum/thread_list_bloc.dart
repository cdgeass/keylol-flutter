import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'thread_list_event.dart';

part 'thread_list_state.dart';

class ThreadListBloc extends Bloc<ThreadListEvent, ThreadListState> {
  final _logger = Logger();

  final KeylolApiClient _client;

  final String _fid;
  final String? _typeId;

  ThreadListBloc({
    required KeylolApiClient client,
    required String fid,
    String? typeId,
  })  : _client = client,
        _fid = fid,
        _typeId = typeId,
        super(ThreadListState(status: ThreadListStatus.initial)) {
    on<ThreadListReloaded>(_onReloaded);
    on<ThreadListLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    ThreadListReloaded event,
    Emitter<ThreadListState> emit,
  ) async {
    try {
      final filter = event.filter;
      final param = event.param;

      final forumDisplay = await _client.fetchForum(
        fid: _fid,
        page: 0,
        typeId: _typeId,
        filter: filter,
        param: param,
      );
      final threads = forumDisplay.threads ?? const [];

      emit(state.copyWith(
        status: ThreadListStatus.success,
        page: 1,
        threads: threads,
        hasReachedMax: threads.length < 20,
        filter: filter,
        param: param,
      ));
    } catch (error) {
      _logger.e('[版块] 获取版块帖子出错', error);
    }
  }

  Future<void> _onLoaded(
    ThreadListEvent event,
    Emitter<ThreadListState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }

    try {
      final page = state.page;
      final filter = state.filter;
      final param = state.param;

      final forumDisplay = await _client.fetchForum(
        fid: _fid,
        page: page + 1,
        typeId: _typeId,
        filter: filter,
        param: param,
      );
      final threads = forumDisplay.threads ?? const [];

      if (threads.isEmpty) {
        emit(state.copyWith(
          status: ThreadListStatus.success,
          hasReachedMax: true,
          filter: filter,
          param: param,
        ));
      } else {
        final finalThreads = state.threads;
        threads.forEach((thread) {
          if (!finalThreads.any((t) => t.tid == thread.tid)) {
            finalThreads.add(thread);
          }
        });

        emit(state.copyWith(
          status: ThreadListStatus.success,
          page: page + 1,
          threads: finalThreads,
          filter: filter,
          param: param,
        ));
      }
    } catch (error) {
      _logger.e('[版块] 加载版块帖子出错', error);
    }
  }
}
