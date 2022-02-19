import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/common/log.dart';
import 'package:stream_transform/stream_transform.dart';

part 'index_event.dart';

part 'index_state.dart';

const throttleDuration = Duration(seconds: 1);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  final _logger = Log();
  final KeylolApiClient _client;

  IndexBloc({
    required KeylolApiClient client,
  })  : _client = client,
        super(IndexState()) {
    on<IndexFetched>(
      _onIndexFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _onIndexFetched(
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
      _logger.e('获取首页内容出错', error);
      emit(state.copyWith(status: IndexStatus.failure));
    }
  }
}
