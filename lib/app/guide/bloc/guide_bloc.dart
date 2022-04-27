import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'guide_event.dart';

part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final _logger = Logger();
  final KeylolApiClient _client;
  final String _type;

  GuideBloc({
    required KeylolApiClient client,
    required String type,
  })  : _client = client,
        _type = type,
        super(GuideState(status: GuideStatus.initial)) {
    on<GuideReloaded>(_onReloaded);
    on<GuideLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    GuideEvent event,
    Emitter<GuideState> emit,
  ) async {
    try {
      final guide = await _client.fetchGuide(type: _type, page: 1);
      final totalPage = guide.totalPage;
      final threads = guide.threadList;

      emit(state.copyWith(
        status: GuideStatus.success,
        page: 1,
        threads: threads,
        hasReachedMax: 1 == totalPage,
      ));
    } catch (error) {
      _logger.e('[导读] 获取 type: $_type 出错', error);

      emit(state.copyWith(status: GuideStatus.failure));
    }
  }

  Future<void> _onLoaded(
    GuideEvent event,
    Emitter<GuideState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      final page = state.page + 1;

      final guide = await _client.fetchGuide(type: _type, page: page);
      final totalPage = guide.totalPage;
      final threads = guide.threadList;

      final finalThreads = state.threads;
      threads.forEach((thread) {
        if (!finalThreads.any((t) => t.tid == thread.tid)) {
          finalThreads.add(thread);
        }
      });

      emit(state.copyWith(
        status: GuideStatus.success,
        page: page,
        threads: finalThreads,
        hasReachedMax: page == totalPage,
      ));
    } catch (error) {
      _logger.e('[导读] 加载 type: $_type 出错', error);

      emit(state.copyWith(status: GuideStatus.failure));
    }
  }
}
