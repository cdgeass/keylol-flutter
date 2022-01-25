part of './thread_list_bloc.dart';

enum ThreadListStatus { initial, success, failure }

class ThreadListState extends Equatable {
  final ThreadListStatus status;
  final int page;
  final List<ForumDisplayThread> threads;
  final bool hasReachedMax;

  final String? filter;
  final Map<String, String>? param;

  ThreadListState({
    required this.status,
    this.page = 1,
    this.threads = const [],
    this.hasReachedMax = false,
    this.filter,
    this.param,
  });

  ThreadListState copyWith({
    ThreadListStatus? status,
    int? page,
    List<ForumDisplayThread>? threads,
    bool? hasReachedMax,
    String? filter,
    Map<String, String>? param,
  }) {
    return ThreadListState(
      status: status ?? this.status,
      page: page ?? this.page,
      threads: threads ?? this.threads,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filter: filter,
      param: param,
    );
  }

  @override
  List<Object?> get props => [status, page, threads, hasReachedMax];
}
