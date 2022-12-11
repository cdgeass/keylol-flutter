part of 'forum_index_bloc.dart';

enum ForumIndexStatus { initial, success }

class ForumIndexState extends Equatable {
  final ForumIndexStatus status;
  final List<Cat>? cats;

  final Object? error;

  ForumIndexState({required this.status, this.cats, this.error});

  ForumIndexState copyWith({
    ForumIndexStatus? status,
    List<Cat>? cats,
    Object? error,
  }) {
    return ForumIndexState(
        status: status ?? this.status,
        cats: cats ?? this.cats,
        error: error ?? this.error);
  }

  @override
  List<Object?> get props => [status, cats, error];
}
