part of 'space_reply_bloc.dart';

abstract class SpaceReplyEvent extends Equatable {

  @override
  List<Object?> get props => [];
}

class SpaceReplyReloaded extends SpaceReplyEvent {}

class SpaceReplyLoaded extends SpaceReplyEvent {}
