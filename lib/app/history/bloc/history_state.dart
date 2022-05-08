part of 'history_bloc.dart';

enum HistoryStatus { initial, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<Thread> threads;

  HistoryState({
    required this.status,
    this.threads = const [],
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<Thread>? threads,
  }) {
    return HistoryState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
    );
  }

  @override
  List<Object?> get props => [status, threads];
}
