part of 'space_bloc.dart';

enum SpaceStatus { initial, success, failure }

class SpaceState extends Equatable {
  final SpaceStatus status;

  final Space? space;

  SpaceState({
    required this.status,
    this.space,
  });

  SpaceState copyWith({
    SpaceStatus? status,
    Space? space,
  }) {
    return SpaceState(
      status: status ?? this.status,
      space: space ?? this.space,
    );
  }

  @override
  List<Object?> get props => [status, space];
}
