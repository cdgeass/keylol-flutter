part of './thread_list_bloc.dart';

abstract class ThreadListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThreadListReloaded extends ThreadListEvent {}

class ThreadListLoaded extends ThreadListEvent {}
