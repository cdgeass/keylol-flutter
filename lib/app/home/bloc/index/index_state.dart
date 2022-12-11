part of './index_bloc.dart';

enum IndexStatus { initial, success, failure }

class IndexState extends Equatable {
  final IndexStatus status;
  final Index? index;
  final Object? error;

  IndexState({
    required this.status,
    this.index,
    this.error,
  });

  IndexState copyWith({
    IndexStatus? status,
    Index? index,
    Object? error,
  }) {
    return IndexState(
      status: status ?? this.status,
      index: index ?? this.index,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, index];
}
