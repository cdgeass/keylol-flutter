part of 'space_thread_bloc.dart';

enum SpaceThreadStatus { initial, success, failure }

class SpaceThreadState extends Equatable {
  final SpaceThreadStatus status;

  final int page;
  final List<Thread> threads;
  final bool hasReachedMax;

  SpaceThreadState({
    required this.status,
    this.page = 0,
    this.threads = const [],
    this.hasReachedMax = false,
  });

  SpaceThreadState copyWith({
    SpaceThreadStatus? status,
    int? page,
    List<Thread>? threads,
    bool? hasReachedMax,
  }) {
    return SpaceThreadState(
      status: status ?? this.status,
      page: page ?? this.page,
      threads: threads ?? this.threads,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, page, threads, hasReachedMax];
}
