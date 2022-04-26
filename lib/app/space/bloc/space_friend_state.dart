part of 'space_friend_bloc.dart';

enum SpaceFriendStatus { initial, success, failure }

class SpaceFriendState extends Equatable {
  final SpaceFriendStatus status;

  final int page;
  final List<Friend> friends;
  final bool hasReachedMax;

  SpaceFriendState({
    required this.status,
    this.page = 0,
    this.friends = const [],
    this.hasReachedMax = false,
  });

  SpaceFriendState copyWith({
    SpaceFriendStatus? status,
    int? page,
    List<Friend>? friends,
    bool? hasReachedMax,
  }) {
    return SpaceFriendState(
      status: status ?? this.status,
      page: page ?? this.page,
      friends: friends ?? this.friends,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, page, friends];
}
