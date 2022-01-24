part of './forum_bloc.dart';

enum ForumStatus { initial, success, failure }

class ForumState extends Equatable {
  final ForumStatus status;
  final ForumDisplayForum? forum;
  final List<ForumDisplayThreadType> types;

  ForumState({
    required this.status,
    this.forum,
    this.types = const [],
  });

  ForumState copyWith({
    ForumStatus? status,
    ForumDisplayForum? forum,
    List<ForumDisplayThreadType>? types,
    String? typeId,
  }) {
    return ForumState(
      status: status ?? this.status,
      forum: forum ?? this.forum,
      types: types ?? this.types,
    );
  }

  @override
  List<Object?> get props => [status, types];
}
