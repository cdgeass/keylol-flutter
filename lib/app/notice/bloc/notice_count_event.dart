part of 'notice_count_bloc.dart';

abstract class NoticeCountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoticeCountUpdated extends NoticeCountEvent {
  final Notice notice;

  NoticeCountUpdated(this.notice);
}
