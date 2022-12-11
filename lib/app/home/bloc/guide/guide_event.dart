part of './guide_bloc.dart';

abstract class GuideEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GuideReloaded extends GuideEvent {}

class GuideLoaded extends GuideEvent {}
