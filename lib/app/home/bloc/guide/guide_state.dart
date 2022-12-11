part of './guide_bloc.dart';

enum GuideStatus { initial, success }

class GuideState extends Equatable {
  final GuideStatus status;

  final bool hasReachedMax;
  final int page;
  final List<Thread>? threads;

  final Object? error;

  GuideState({
    this.status = GuideStatus.initial,
    this.hasReachedMax = false,
    this.page = 1,
    this.threads,
    this.error,
  });

  GuideState copyWith({
    GuideStatus? status,
    int? page,
    List<Thread>? threads,
    bool? hasReachedMax,
    Object? error,
  }) {
    return GuideState(
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      threads: threads ?? this.threads,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, hasReachedMax, page, threads, error];
}
