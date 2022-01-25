part of './thread_bloc.dart';

enum ThreadStatus { initial, success, failure }

class ThreadState extends Equatable {
  final ThreadStatus status;
  final Thread? thread;

  ThreadState({
    required this.status,
    this.thread,
  });

  ThreadState copyWith({
    ThreadStatus? status,
    Thread? thread,
  }) {
    return ThreadState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
    );
  }

  @override
  List<Object?> get props => [];
}
