import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'forum_index_event.dart';

part 'forum_index_state.dart';

class ForumIndexBloc extends Bloc<ForumIndexEvent, ForumIndexState> {
  final _logger = Logger();

  final KeylolApiClient _client;

  ForumIndexBloc({required KeylolApiClient client})
      : _client = client,
        super(ForumIndexState(status: ForumIndexStatus.initial)) {
    on<ForumIndexFetched>(_onFetched);
    on<ForumIndexSelected>(_onSelected);
  }

  Future<void> _onFetched(
    ForumIndexEvent event,
    Emitter<ForumIndexState> emit,
  ) async {
    try {
      final cats = await _client.fetchForumIndex();
      emit(state.copyWith(status: ForumIndexStatus.success, cats: cats));
    } catch (error) {
      _logger.e('[版块] 获取版块索引出错', error);

      emit(state.copyWith(status: ForumIndexStatus.failure));
    }
  }

  Future<void> _onSelected(
    ForumIndexSelected event,
    Emitter<ForumIndexState> emit,
  ) async {
    final selected = event.selected;
    emit(state.copyWith(selected: selected));
  }
}
