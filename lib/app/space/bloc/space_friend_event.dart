part of 'space_friend_bloc.dart';

abstract class SpaceFriendEvent extends Equatable {
  const SpaceFriendEvent();

  @override
  List<Object?> get props => [];
}

class SpaceFriendReloaded extends SpaceFriendEvent {}

class SpaceFriendLoaded extends SpaceFriendEvent {}
