part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryReloaded extends HistoryEvent {
  final String? text;

  HistoryReloaded([this.text]);
}

class HistoryDeleted extends HistoryEvent {
  final String tid;

  HistoryDeleted(this.tid);
}