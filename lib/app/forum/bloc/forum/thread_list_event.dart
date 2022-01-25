part of './thread_list_bloc.dart';

abstract class ThreadListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThreadListReloaded extends ThreadListEvent {
  final String? filter;
  final Map<String, String>? param;

  ThreadListReloaded({this.filter, this.param});
}

class ThreadListLoaded extends ThreadListEvent {}
