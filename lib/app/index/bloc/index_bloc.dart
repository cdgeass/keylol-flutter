import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart' as parser;
import 'package:keylol_flutter/app/index/models/models.dart';
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
  final Dio client;

  IndexBloc({required this.client}) : super(IndexState()) {
    on<IndexFetched>(
      _onIndexFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<Index> _fetchIndex() async {
    var res = await client.get("");
    var document = parser.parse(res.data);
    return Index.fromDocument(document);
  }

  Future<void> _onIndexFetched(
    IndexEvent event,
    Emitter<IndexState> emit,
  ) async {
    try {
      final index = await _fetchIndex();
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
