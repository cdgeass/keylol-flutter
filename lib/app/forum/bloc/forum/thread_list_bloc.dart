import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  Future<void> _onReloaded(
    ThreadListEvent event,
    Emitter<ThreadListState> emit,
  ) async {
    try {
      final threads = await _fetch(1);

      emit(state.copyWith(
        status: ThreadListStatus.loaded,
        page: 1,
        threads: threads,
        hasReachedMax: false,
      ));
    } catch (error) {
      _logger.e('初始化获取版块帖子错误', error);
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
    } else {}

    var res = await client.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']).threads ?? [];
  }
}
