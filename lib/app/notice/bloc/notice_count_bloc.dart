import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/models/notice.dart';
import 'package:keylol_flutter/repository/notice_repository.dart';

part 'notice_count_event.dart';

part 'notice_count_state.dart';

class NoticeCountBloc extends Bloc<NoticeCountEvent, NoticeCountState> {
  final NoticeRepository repository;

  NoticeCountBloc(this.repository) : super(NoticeCountState(EMPTY_NOTICE)) {
    on<NoticeCountUpdated>(_onUpdated);

    this.repository.registerCallback((notice) {
      this.add(NoticeCountUpdated(notice));
    });
  }

  Future<void> _onUpdated(
    NoticeCountUpdated event,
    Emitter<NoticeCountState> emit,
  ) async {
    if (state.notice != event.notice) {
      emit(state.copyWith(event.notice));
    }
  }
}
