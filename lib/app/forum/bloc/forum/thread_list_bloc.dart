import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/bloc/forum/forum_bloc.dart';
import 'package:keylol_flutter/app/forum/models/models.dart';
import 'package:keylol_flutter/common/log.dart';

part './thread_list_event.dart';

part './thread_list_state.dart';

class ThreadListBloc extends Bloc<ThreadListEvent, ThreadListState> {
  final _logger = Log();
  final Dio client;

  final String fid;
  final String? typeId;

  ThreadListBloc({
    required this.client,
    required this.fid,
    this.typeId,
  }) : super(ThreadListState(status: ThreadListStatus.initial)) {
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

      final threads = await _fetch(1, filter: filter, param: param);

      emit(state.copyWith(
        status: ThreadListStatus.success,
        page: 1,
        threads: threads,
        hasReachedMax: false,
        filter: filter,
        param: param,
      ));
    } catch (error) {
      _logger.e('初始化获取版块帖子错误', error);
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

      final threads = await _fetch(page + 1, filter: filter, param: param);

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
      _logger.e('加载更多版块帖子错误', error);
    }
  }

  Future<List<ForumDisplayThread>> _fetch(
    int page, {
    String? filter,
    Map<String, String>? param,
  }) async {
    final queryParameters = {
      'module': 'forumdisplay',
      'fid': fid,
      'page': page,
    };

    if (typeId != null) {
      queryParameters.addAll({
        'filter': 'typeid',
        'typeid': typeId!,
      });
    } else if (filter != null && param != null) {
      queryParameters.addAll({'filter': filter});
      queryParameters.addAll(param);
    }

    var res = await client.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']).threads ?? [];
  }
}
