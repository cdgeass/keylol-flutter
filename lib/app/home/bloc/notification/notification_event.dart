part of './notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationReloaded extends NotificationEvent {}

class NotificationLoaded extends NotificationEvent {}
