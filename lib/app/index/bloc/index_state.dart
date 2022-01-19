part of 'index_bloc.dart';

enum IndexStatus { initial, success, failure }

class IndexState {
  final IndexStatus status;
  final Index? index;

  IndexState({this.status = IndexStatus.initial, this.index});

  IndexState copyWith({
    IndexStatus? status,
    Index? index
  }) {
    return IndexState(
        status: status ?? this.status, index: index ?? this.index);
  }
}
