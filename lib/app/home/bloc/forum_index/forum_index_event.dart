part of 'forum_index_bloc.dart';

abstract class ForumIndexEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForumIndexReloaded extends ForumIndexEvent {}