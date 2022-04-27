part of './notice_bloc.dart';

enum NoticeStatus { initial, success, failure }

class NoticeState extends Equatable {
  final NoticeStatus status;

  final int page;
  final int total;
  final List<Note> notes;

  NoticeState({
    required this.status,
    this.page = 1,
    this.total = 0,
    this.notes = const [],
  });

  NoticeState copyWith({
    NoticeStatus? status,
    int? page,
    int? total,
    List<Note>? notes,
  }) {
    return NoticeState(
      status: status ?? this.status,
      page: page ?? this.page,
      total: total ?? this.total,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [status, page, total, notes];
}
