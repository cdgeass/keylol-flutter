import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:keylol_flutter/model/notice.dart';

part './notice_event.dart';

part './notice_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final _logger = Log();
  final Dio client;

  NoticeBloc({
    required this.client,
  }) : super(NoticeState(status: NoticeStatus.initial)) {
    on<NoticeReloaded>(_onReloaded);
    on<NoticeLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    NoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      final noteList = await _fetchNoteList(page: 1);

      final total = noteList.count;
      final notes = noteList.list;

      emit(state.copyWity(
        status: NoticeStatus.success,
        page: 1,
        total: total,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('', error);
      emit(state.copyWity(status: NoticeStatus.failure));
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

      final noteList = await _fetchNoteList(page: page);
      if (noteList.list.isEmpty) {
        return;
      }

      final total = noteList.count;
      final notes = state.notes..addAll(noteList.list);

      emit(state.copyWity(
        status: NoticeStatus.success,
        page: page,
        total: total,
        notes: notes,
      ));
    } catch (error) {
      _logger.e('', error);
      emit(state.copyWity(status: NoticeStatus.failure));
    }
  }

  // 提醒列表
  Future<NoteList> _fetchNoteList({required int page}) async {
    final res = await client.post('/api/mobile/index.php',
        queryParameters: {'module': 'mynotelist', 'page': page});

    if (res.data['Message'] != null) {
      return Future.error(res.data['Message']?['messagestr']);
    }
    return NoteList.fromJson(res.data['Variables']);
  }
}
