import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'forum_event.dart';

part 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final _logger = Logger();
  final KeylolApiClient _client;
  final String _fid;

  ForumBloc({required KeylolApiClient client, required String fid})
      : _client = client,
        _fid = fid,
        super(ForumState(status: ForumStatus.initial)) {
    on<ForumDetailFetched>(_onFetched);
  }

  Future<void> _onFetched(
    ForumEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final forumDisplay = await _client.fetchForum(fid: _fid);

      emit(state.copyWith(
        status: ForumStatus.success,
        forum: forumDisplay.forum,
        types: forumDisplay.threadTypes,
      ));
    } catch (error) {
      _logger.e('[版块] 获取版块详情出错', error);
    }
  }
}
