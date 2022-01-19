import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/models/index.dart';

part 'index_event.dart';

part 'index_state.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  IndexBloc() : super(IndexState()) {
    on<IndexFetched>(
      _onIndexFetched,
    );
  }

  Future<void> _onIndexFetched(
    IndexEvent event,
    Emitter<IndexState> emit,
  ) async {
    try {
      if (state.status == IndexStatus.initial) {
        final index = await KeylolClient().fetchIndex();
        return emit(state.copyWith(
          status: IndexStatus.success,
          index: index,
        ));
      }
    } catch (error) {
      print(error);
      emit(state.copyWith(status: IndexStatus.failure));
    }
  }
}
