import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/repository/history_repository.dart';
import 'package:logger/logger.dart';

part 'history_event.dart';

part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final _logger = Logger();
  final HistoryRepository _historyRepository;

  HistoryBloc({required HistoryRepository historyRepository})
      : _historyRepository = historyRepository,
        super(HistoryState(status: HistoryStatus.initial)) {
    on<HistoryReloaded>(_onReloaded);
  }

  Future<void> _onReloaded(
    HistoryReloaded event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final threads = await _historyRepository.histories();

      emit(state.copyWith(
        status: HistoryStatus.success,
        threads: threads,
      ));
    } catch (error) {
      _logger.e('[历史] 获取历史出错', error);
     
      emit(state.copyWith(status: HistoryStatus.failure));
    }
  }
}
