import 'package:flutter/material.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';

/// Stato condiviso per la barra risposta fissata in fondo alle liste feed.
class FeedInlineReplyState {
  const FeedInlineReplyState({
    required this.ownerId,
    required this.replyDraft,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.hintText,
    required this.onSend,
    required this.onCancel,
  });

  final int ownerId;
  final FeedCommentReplyDraft replyDraft;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback onCancel;
}

/// Bus per aprire/chiudere la barra risposta nel newsfeed/profilo.
class FeedInlineReplyHost {
  FeedInlineReplyHost._();

  static final active = ValueNotifier<FeedInlineReplyState?>(null);

  static void show(FeedInlineReplyState state) {
    active.value = state;
    requestCommentFocusAfterFrame(state.focusNode);
  }

  static void update(FeedInlineReplyState state) {
    if (active.value?.ownerId == state.ownerId) {
      active.value = state;
    }
  }

  static void hide(int ownerId) {
    if (active.value?.ownerId == ownerId) {
      active.value = null;
    }
  }

  static void hideAll() {
    active.value = null;
  }
}

/// Barra risposta in fondo alla pagina (newsfeed, profilo, tag feed).
class FeedInlineReplyBar extends StatelessWidget {
  const FeedInlineReplyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FeedInlineReplyState?>(
      valueListenable: FeedInlineReplyHost.active,
      builder: (context, state, _) {
        if (state == null) return const SizedBox.shrink();
        return FeedCommentBar(
          controller: state.controller,
          focusNode: state.focusNode,
          isSending: state.isSending,
          onSend: state.onSend,
          hintText: state.hintText,
          replyLabel: state.replyDraft.replyLabel,
          onCancelReply: state.onCancel,
        );
      },
    );
  }
}

/// Richiede focus al [focusNode] dopo il prossimo frame (evita perdita tastiera).
void requestCommentFocusAfterFrame(FocusNode focusNode, {State? mountedOn}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mountedOn != null && !mountedOn.mounted) return;
      if (!focusNode.canRequestFocus) return;
      focusNode.requestFocus();
    });
  });
}
