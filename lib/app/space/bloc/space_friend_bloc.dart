import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'space_friend_event.dart';

part 'space_friend_state.dart';

class SpaceFriendBloc extends Bloc<SpaceFriendEvent, SpaceFriendState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  final String _uid;

  SpaceFriendBloc({
    required KeylolApiClient client,
    required String uid,
  })  : _client = client,
        _uid = uid,
        super(SpaceFriendState(status: SpaceFriendStatus.initial)) {
    on<SpaceFriendReloaded>(_onReloaded);
    on<SpaceFriendLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    SpaceFriendEvent event,
    Emitter<SpaceFriendState> emit,
  ) async {
    try {
      final spaceFriend = await _client.fetchFriend(_uid);

      final friends = spaceFriend.friendList;
      final hasReachedMax = spaceFriend.count == friends.length;

      emit(state.copyWith(
        status: SpaceFriendStatus.success,
        page: 0,
        friends: friends,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('[空间] 获取用户 $_uid 好友出错', error);
    }
  }

  Future<void> _onLoaded(
    SpaceFriendEvent event,
    Emitter<SpaceFriendState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      final page = state.page + 1;

      final spaceFriend = await _client.fetchFriend(_uid, page: page);

      final friends = spaceFriend.friendList;
      if (friends.isEmpty) {
        emit(state.copyWith(
          status: SpaceFriendStatus.success,
          hasReachedMax: true,
        ));
      } else {
        final finalFriends = state.friends;
        friends.forEach((friend) {
          if (!finalFriends.any((f) => f.uid == friend.uid)) {
            finalFriends.add(friend);
          }
        });

        final hasReachedMax = spaceFriend.count == finalFriends.length;

        emit(state.copyWith(
          status: SpaceFriendStatus.success,
          page: page,
          friends: finalFriends,
          hasReachedMax: hasReachedMax,
        ));
      }
    } catch (error) {
      _logger.e('[空间] 加载用户 $_uid 好友出错', error);
    }
  }
}
