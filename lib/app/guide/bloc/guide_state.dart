part of './guide_bloc.dart';

enum GuideStatus { initial, success, failure }

class GuideState extends Equatable {
  final GuideStatus status;

  final int page;
  final List<Thread> threads;

  final bool hasReachedMax;

  GuideState({
    required this.status,
    this.page = 1,
    this.threads = const [],
    this.hasReachedMax = false,
  });

  GuideState copyWith({
    GuideStatus? status,
    int? page,
    List<Thread>? threads,
    bool? hasReachedMax,
  }) {
    return GuideState(
      status: status ?? this.status,
      page: page ?? this.page,
      threads: threads ?? this.threads,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, page, threads, hasReachedMax];
}
