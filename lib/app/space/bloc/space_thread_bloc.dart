import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'space_thread_event.dart';

part 'space_thread_state.dart';

class SpaceThreadBloc extends Bloc<SpaceThreadEvent, SpaceThreadState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  final String _uid;

  SpaceThreadBloc({
    required KeylolApiClient client,
    required String uid,
  })  : _client = client,
        _uid = uid,
        super(SpaceThreadState(status: SpaceThreadStatus.initial)) {
    on<SpaceThreadReloaded>(_onReloaded);
    on<SpaceThreadLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    SpaceThreadReloaded event,
    Emitter<SpaceThreadState> emit,
  ) async {
    try {
      final int page = 0;

      final spaceReply = await _client.fetchSpaceThread(_uid, page: page);

      final threads = spaceReply.threadList;
      final hasReachedMax = threads.isEmpty;

      emit(state.copyWith(
        status: SpaceThreadStatus.success,
        page: page,
        threads: threads,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('[空间] 获取用户 $_uid 主题出错', error);
    }
  }

  Future<void> _onLoaded(
    SpaceThreadLoaded event,
    Emitter<SpaceThreadState> emit,
  ) async {
    try {
      final page = state.page + 1;

      final spaceThread = await _client.fetchSpaceThread(_uid, page: page);

      final threads = spaceThread.threadList;
      final hasReachedMax = threads.isEmpty;

      final finalThreads = state.threads;
      threads.forEach((reply) {
        if (!finalThreads.any((r) => r.tid == reply.tid)) {
          finalThreads.add(reply);
        }
      });

      emit(state.copyWith(
        status: SpaceThreadStatus.success,
        page: page,
        threads: finalThreads,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('[空间] 加载用户 $_uid 主题出错', error);
    }
  }
}
