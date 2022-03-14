part of 'fav_thread_bloc.dart';

abstract class FavThreadEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FavThreadLoaded extends FavThreadEvent {}

class FavThreadReloaded extends FavThreadEvent {}

class FavThreadDelete extends FavThreadEvent {
  final String favId;

  FavThreadDelete(this.favId);
}
