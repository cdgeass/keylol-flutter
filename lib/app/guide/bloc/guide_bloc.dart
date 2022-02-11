import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:keylol_flutter/app/thread/models/thread.dart';
import 'package:keylol_flutter/models/guide.dart';

import '../../../common/log.dart';

part './guide_event.dart';

part './guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final _logger = Log();
  final Dio client;
  final String type;

  GuideBloc({
    required this.client,
    required this.type,
  }) : super(GuideState(status: GuideStatus.initial)) {
    on<GuideReloaded>(_onReloaded);
    on<GuideLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    GuideEvent event,
    Emitter<GuideState> emit,
  ) async {
    try {
      final guide = await _fetchGuide(page: 1);
      final totalPage = guide.totalPage;
      final threads = guide.threadList;

      emit(state.copyWith(
        status: GuideStatus.success,
        page: 1,
        threads: threads,
        hasReachedMax: 1 == totalPage,
      ));
    } catch (error) {
      _logger.e('获取导读 $type 错误', error);
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

      final guide = await _fetchGuide(page: page);
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
      _logger.e('加载导读 $type 错误', error);
      emit(state.copyWith(status: GuideStatus.failure));
    }
  }

  Future<Guide> _fetchGuide({int page = 1}) async {
    final res = await client.get('/forum.php',
        queryParameters: {'mod': 'guide', 'view': type, 'page': page});
    final document = parse(res.data);
    return Guide.fromDocument(document);
  }
}
