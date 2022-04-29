import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';
import 'package:logger/logger.dart';

part 'space_reply_event.dart';

part 'space_reply_state.dart';

class SpaceReplyBloc extends Bloc<SpaceReplyEvent, SpaceReplyState> {
  final _logger = Logger();
  final KeylolApiClient _client;

  final String _uid;

  SpaceReplyBloc({
    required KeylolApiClient client,
    required String uid,
  })  : _client = client,
        _uid = uid,
        super(SpaceReplyState(status: SpaceReplyStatus.initial)) {
    on<SpaceReplyReloaded>(_onReloaded);
    on<SpaceReplyLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    SpaceReplyReloaded event,
    Emitter<SpaceReplyState> emit,
  ) async {
    try {
      final int page = 0;

      final spaceReply = await _client.fetchSpaceReply(_uid, page: page);

      final replies = spaceReply.replyList;
      final hasReachedMax = replies.isEmpty;

      emit(state.copyWith(
        status: SpaceReplyStatus.success,
        page: page,
        replies: replies,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('[空间] 获取用户 $_uid 回复出错', error);
    }
  }

  Future<void> _onLoaded(
    SpaceReplyLoaded event,
    Emitter<SpaceReplyState> emit,
  ) async {
    try {
      final page = state.page + 1;

      final spaceReply = await _client.fetchSpaceReply(_uid, page: page);

      final replies = spaceReply.replyList;
      final hasReachedMax = replies.isEmpty;

      final finalReplies = state.replies;
      replies.forEach((reply) {
        if (!finalReplies.any((r) => r.tid == reply.tid)) {
          finalReplies.add(reply);
        }
      });

      emit(state.copyWith(
        status: SpaceReplyStatus.success,
        page: page,
        replies: finalReplies,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {
      _logger.e('[空间] 加载用户 $_uid 回复出错', error);
    }
  }
}
