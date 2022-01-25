import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/app/forum/models/models.dart';
import 'package:keylol_flutter/common/log.dart';

part './forum_event.dart';

part './forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final _logger = Log();
  final Dio client;
  final String fid;

  ForumBloc({required this.client, required this.fid})
      : super(ForumState(status: ForumStatus.initial)) {
    on<ForumDetailFetched>(_onFetched);
  }

  Future<void> _onFetched(
    ForumEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final forumDisplay = await _fetch(1);

      emit(state.copyWith(
        status: ForumStatus.success,
        forum: forumDisplay.forum,
        types: forumDisplay.threadTypes,
      ));
    } catch (error) {
      _logger.e('获取版块详情错误', error);
    }
  }

  Future<ForumDisplay> _fetch(int page) async {
    final queryParameters = {
      'module': 'forumdisplay',
      'fid': fid,
      'page': page,
    };
    var res = await client.get("/api/mobile/index.php",
        queryParameters: queryParameters);

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']!['messagestr']);
    }
    return ForumDisplay.fromJson(res.data['Variables']);
  }
}
