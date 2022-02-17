part of './notice_bloc.dart';

abstract class NoticeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoticeReloaded extends NoticeEvent {}

class NoticeLoaded extends NoticeEvent {}
