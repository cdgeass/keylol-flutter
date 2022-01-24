part of './thread_list_bloc.dart';

enum ThreadListStatus { initial, loading, loaded, failure }

class ThreadListState extends Equatable {
  final ThreadListStatus status;
  final int page;
  final List<ForumDisplayThread> threads;
  final bool hasReachedMax;

  ThreadListState({
    required this.status,
    this.page = 1,
    this.threads = const [],
    this.hasReachedMax = false,
  });

  ThreadListState copyWith({
    ThreadListStatus? status,
    int? page,
    List<ForumDisplayThread>? threads,
    bool? hasReachedMax,
  }) {
    return ThreadListState(
      status: status ?? this.status,
      page: page ?? this.page,
      threads: threads ?? this.threads,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, page, threads, hasReachedMax];
}
