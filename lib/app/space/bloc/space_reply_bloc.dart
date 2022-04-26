import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keylol_flutter/api/keylol_api.dart';

part 'space_reply_event.dart';

part 'space_reply_state.dart';

class SpaceReplyBloc extends Bloc<SpaceReplyEvent, SpaceReplyState> {
  final KeylolApiClient client;

  final String uid;

  SpaceReplyBloc({
    required this.client,
    required this.uid,
  }) : super(SpaceReplyState(status: SpaceReplyStatus.initial)) {
    on<SpaceReplyReloaded>(_onReloaded);
    on<SpaceReplyLoaded>(_onLoaded);
  }

  Future<void> _onReloaded(
    SpaceReplyReloaded event,
    Emitter<SpaceReplyState> emit,
  ) async {
    try {
      final int page = 0;

      final spaceReply = await client.fetchSpaceReply(uid, page: page);

      final replies = spaceReply.replyList;
      final hasReachedMax = replies.isEmpty;

      emit(state.copyWith(
        status: SpaceReplyStatus.success,
        page: page,
        replies: replies,
        hasReachedMax: hasReachedMax,
      ));
    } catch (error) {}
  }

  Future<void> _onLoaded(
    SpaceReplyLoaded event,
    Emitter<SpaceReplyState> emit,
  ) async {
    try {
      final page = state.page + 1;

      final spaceReply = await client.fetchSpaceReply(uid, page: page);

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
    } catch (error) {}
  }
}
