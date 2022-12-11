import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'notification_event.dart';

part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  NotificationBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(NotificationState(status: NotificationStatus.initial)) {
    on<NotificationReloaded>(_onReloaded);
    on<NotificationLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    NotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final noteList = await _client.fetchNoteList(page: 1);

      final total = noteList.count;
      final notes = noteList.list;

      emit(state.copyWith(
        status: NotificationStatus.success,
        hasReachedMax: notes.length == total,
        page: 1,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('[提醒] 获取提醒出错', error);

      emit(state.copyWith(error: error));
    }
  }

  Future<void> _onLoaded(
    NotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }

    try {
      final page = state.page + 1;

      final noteList = await _client.fetchNoteList(page: page);
      if (noteList.list.isEmpty) {
        return;
      }

      final total = noteList.count;
      final notes = (state.notes ?? [])..addAll(noteList.list);

      emit(state.copyWith(
        status: NotificationStatus.success,
        hasReachedMax: notes.length == total,
        page: page,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('[提醒] 加载提醒出错', error);

      emit(state.copyWith(error: error));
    }
  }
}
