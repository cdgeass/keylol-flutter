part of 'fav_thread_bloc.dart';

enum FavThreadStatus { initial, success, failure }

class FavThreadState extends Equatable {
  final FavThreadStatus status;

  final List<FavThread> favThreads;

  FavThreadState({
    required this.status,
    this.favThreads = const [],
  });

  FavThreadState copy({
    FavThreadStatus? status,
    List<FavThread>? favThreads,
  }) {
    return FavThreadState(
      status: status ?? this.status,
      favThreads: favThreads ?? this.favThreads,
    );
  }

  @override
  List<Object?> get props => [];
}
