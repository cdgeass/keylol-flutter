part of './notification_bloc.dart';

enum NotificationStatus { initial, success }

class NotificationState extends Equatable {
  final NotificationStatus status;

  final bool hasReachedMax;
  final int page;
  final List<Note>? notes;

  final Object? error;

  NotificationState({
    required this.status,
    this.hasReachedMax = false,
    this.page = 1,
    this.notes,
    this.error,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    bool? hasReachedMax,
    int? page,
    List<Note>? notes,
    Object? error,
  }) {
    return NotificationState(
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      notes: notes ?? this.notes,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, hasReachedMax, page, notes, error];
}
