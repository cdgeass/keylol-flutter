import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:keylol_flutter/repository/repository.dart';

part 'fav_thread_event.dart';

part 'fav_thread_state.dart';

class FavThreadBloc extends Bloc<FavThreadEvent, FavThreadState> {
  final FavThreadRepository repository;

  FavThreadBloc({
    required this.repository,
  }) : super(FavThreadState(status: FavThreadStatus.initial)) {
    on<FavThreadLoaded>(_onLoaded);
    on<FavThreadReloaded>(_onReloaded);
    on<FavThreadDelete>(_onDelete);
  }

  Future<void> _onLoaded(
    FavThreadEvent event,
    Emitter<FavThreadState> emit,
  ) async {
    try {
      final favThreads = await repository.load();
      emit(state.copy(
        status: FavThreadStatus.success,
        favThreads: favThreads,
      ));
    } catch (error) {}
  }

  Future<void> _onReloaded(
    FavThreadEvent event,
    Emitter<FavThreadState> emit,
  ) async {
    try {
      final favThreads = await repository.forceLoad();
      emit(state.copy(
        status: FavThreadStatus.success,
        favThreads: favThreads,
      ));
    } catch (error) {}
  }

  Future<void> _onDelete(
    FavThreadDelete event,
    Emitter<FavThreadState> emit,
  ) async {
    try {
      final favThreads = await repository.delete(favId: event.favId);
      emit(state.copy(
        status: FavThreadStatus.success,
        favThreads: favThreads,
      ));
    } catch (error) {}
  }
}
