import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'space_event.dart';

part 'space_state.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final _log = Logger();

  final KeylolApiClient client;

  final String uid;

  SpaceBloc({
    required this.client,
    required this.uid,
  }) : super(SpaceState(status: SpaceStatus.initial)) {
    on<SpaceReloaded>(_onReloaded);
  }

  Future<void> _onReloaded(
    SpaceEvent event,
    Emitter<SpaceState> emit,
  ) async {
    try {
      final space = await client.fetchSpace(uid: uid, cached: true);
      emit(state.copyWith(
        status: SpaceStatus.success,
        space: space,
      ));
    } catch (error) {
      _log.e('', error);
    }
  }
}
