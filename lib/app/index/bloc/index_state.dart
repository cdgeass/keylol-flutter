part of 'index_bloc.dart';

enum IndexStatus { initial, success, failure }

class IndexState extends Equatable {
  final IndexStatus status;
  final Index? index;

  IndexState({this.status = IndexStatus.initial, this.index});

  IndexState copyWith({IndexStatus? status, Index? index}) {
    return IndexState(
        status: status ?? this.status, index: index ?? this.index);
  }

  @override
  List<Object?> get props => [status, index];
}
