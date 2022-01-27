part of './thread_bloc.dart';

enum ThreadStatus { initial, success, failure }

class ThreadState extends Equatable {
  final ThreadStatus status;
  final Thread? thread;

  final int page;
  final List<Post> posts;
  final bool hasReachedMax;

  ThreadState({
    required this.status,
    this.thread,
    this.page = 1,
    this.posts = const [],
    this.hasReachedMax = false,
  });

  ThreadState copyWith({
    ThreadStatus? status,
    Thread? thread,
    int? page,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return ThreadState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      page: page ?? this.page,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, thread, posts];
}
