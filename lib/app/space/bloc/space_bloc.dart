import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'space_event.dart';

part 'space_state.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final _log = Logger();

  final KeylolApiClient _client;

  final String _uid;

  SpaceBloc({
    required KeylolApiClient client,
    required String uid,
  })  : _client = client,
        _uid = uid,
        super(SpaceState(status: SpaceStatus.initial)) {
    on<SpaceReloaded>(_onReloaded);
  }

  Future<void> _onReloaded(
    SpaceEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final space = await _client.fetchSpace(uid: _uid, cached: true);
      emit(state.copyWith(
        status: SpaceStatus.success,
        space: space,
      ));
    } catch (error) {
      _log.e('[空间] 获取用户 $_uid 空间出错', error);
    }
  }
}
