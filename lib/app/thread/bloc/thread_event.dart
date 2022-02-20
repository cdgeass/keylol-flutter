part of './thread_bloc.dart';

abstract class ThreadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThreadReloaded extends ThreadEvent {
  final String? pid;

  ThreadReloaded({this.pid});
}

class ThreadLoaded extends ThreadEvent {}

class ThreadFavored extends ThreadEvent {
  final String description;

  ThreadFavored({required this.description});
}

class ThreadUnfavored extends ThreadEvent {}

class ThreadReplied extends ThreadEvent {
  final Post? post;
  final String message;
  final List<String> aIds;

  ThreadReplied({this.post, required this.message, this.aIds = const []});
}
