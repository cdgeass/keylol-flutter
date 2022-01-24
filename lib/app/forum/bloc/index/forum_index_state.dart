part of 'forum_index_bloc.dart';

enum ForumIndexStatus { initial, success, failure }

class ForumIndexState extends Equatable {
  final ForumIndexStatus status;
  final List<Cat> cats;
  final int selected;

  ForumIndexState(
      {required this.status, this.cats = const [], this.selected = 0});

  ForumIndexState copyWith({
    ForumIndexStatus? status,
    List<Cat>? cats,
    int? selected,
  }) {
    return ForumIndexState(
        status: status ?? this.status,
        cats: cats ?? this.cats,
        selected: selected ?? this.selected);
  }

  @override
  List<Object?> get props => [status, cats, selected];
}
