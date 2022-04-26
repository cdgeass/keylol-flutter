part of 'space_reply_bloc.dart';

enum SpaceReplyStatus { initial, success, failure }

class SpaceReplyState extends Equatable {
  final SpaceReplyStatus status;

  final int page;
  final List<SpaceReplyItem> replies;
  final bool hasReachedMax;

  SpaceReplyState({
    required this.status,
    this.page = 0,
    this.replies = const [],
    this.hasReachedMax = false,
  });

  SpaceReplyState copyWith({
    SpaceReplyStatus? status,
    int? page,
    List<SpaceReplyItem>? replies,
    bool? hasReachedMax,
  }) {
    return SpaceReplyState(
      status: status ?? this.status,
      page: page ?? this.page,
      replies: replies ?? this.replies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, page, replies, hasReachedMax];
}
