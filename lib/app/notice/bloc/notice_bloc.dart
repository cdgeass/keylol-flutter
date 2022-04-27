import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'notice_event.dart';

part 'notice_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  NoticeBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(NoticeState(status: NoticeStatus.initial)) {
    on<NoticeReloaded>(_onReloaded);
    on<NoticeLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    NoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      final noteList = await _client.fetchNoteList(page: 1);

      final total = noteList.count;
      final notes = noteList.list;

      emit(state.copyWith(
        status: NoticeStatus.success,
        page: 1,
        total: total,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('[提醒] 获取提醒出错', error);

      emit(state.copyWith(status: NoticeStatus.failure));
    }
  }

  Future<void> _onLoaded(
    NoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    if (state.notes.length >= state.total) {
      return;
    }

    try {
      final page = state.page + 1;

      final noteList = await _client.fetchNoteList(page: page);
      if (noteList.list.isEmpty) {
        return;
      }

      final total = noteList.count;
      final notes = state.notes..addAll(noteList.list);

      emit(state.copyWith(
        status: NoticeStatus.success,
        page: page,
        total: total,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('[提醒] 加载提醒出错', error);

      emit(state.copyWith(status: NoticeStatus.failure));
    }
  }
}
