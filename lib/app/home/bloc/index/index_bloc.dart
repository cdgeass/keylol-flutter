import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part './index_event.dart';

part './index_state.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  IndexBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(IndexState(status: IndexStatus.initial)) {
    on<IndexReloaded>(_onIndexReloaded);
  }

  Future<void> _onIndexReloaded(
    IndexEvent event,
    Emitter<IndexState> emit,
  ) async {
    try {
      final index = await _client.fetchIndex();
      return emit(state.copyWith(
        status: IndexStatus.success,
        index: index,
      ));
    } catch (error) {
      _logger.e('[首页] 获取首页内容出错', error);

      emit(state.copyWith(error: error));
    }
  }
}
