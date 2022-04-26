part of 'space_thread_bloc.dart';

abstract class SpaceThreadEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class SpaceThreadReloaded extends SpaceThreadEvent {}

class SpaceThreadLoaded extends SpaceThreadEvent {}
