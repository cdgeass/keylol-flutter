part of 'forum_index_bloc.dart';

abstract class ForumIndexEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForumIndexFetched extends ForumIndexEvent {}

class ForumIndexSelected extends ForumIndexEvent {
  final int selected;

  ForumIndexSelected(this.selected);
}
