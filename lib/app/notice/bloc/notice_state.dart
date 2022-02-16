part of './notice_bloc.dart';

enum NoticeStatus { initial, success, failure }

class NoticeState extends Equatable {
  final NoticeStatus status;

  NoticeState({required this.status});

  @override
  List<Object?> get props => [status];
}
