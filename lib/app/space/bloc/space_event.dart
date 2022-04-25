part of 'space_bloc.dart';

abstract class SpaceEvent extends Equatable {
  const SpaceEvent();

  @override
  List<Object?> get props => [];
}

class SpaceReloaded extends SpaceEvent {}
