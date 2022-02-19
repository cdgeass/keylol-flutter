part of './thread_bloc.dart';

enum ThreadStatus { initial, success, failure }

class ThreadState extends Equatable {
  final ThreadStatus status;
  final Thread? thread;
  final List<Widget> threadWidgets;

  final int page;
  final List<Post> posts;
  final bool hasReachedMax;

  final String? favId;

  final String? error;

  ThreadState({
    required this.status,
    this.thread,
    this.threadWidgets = const [],
    this.page = 1,
    this.posts = const [],
    this.hasReachedMax = false,
    this.favId,
    this.error,
  });

  ThreadState copyWith({
    ThreadStatus? status,
    Thread? thread,
    List<Widget>? threadWidgets,
    int? page,
    List<Post>? posts,
    bool? hasReachedMax,
    String? favId,
    String? error,
  }) {
    return ThreadState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      threadWidgets: threadWidgets ?? this.threadWidgets,
      page: page ?? this.page,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      favId: favId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, thread, page, posts, hasReachedMax, favId, error];
}
