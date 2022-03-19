part of 'notice_count_bloc.dart';

final EMPTY_NOTICE = Notice(0, 0, 0, 0);

class NoticeCountState extends Equatable {
  final Notice notice;

  NoticeCountState(this.notice);

  NoticeCountState copyWith(Notice? notice) {
    return NoticeCountState(notice ?? this.notice);
  }

  @override
  List<Object?> get props => [notice];
}
