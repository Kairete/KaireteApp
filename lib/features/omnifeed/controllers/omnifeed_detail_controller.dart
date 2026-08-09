import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_feed_comment_service.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_comment_ui.dart';

class OmnifeedDetailController extends GetxController {
  OmnifeedDetailController({required this.initialItem});

  final OmnifeedItem initialItem;
  final OmnifeedService _service = OmnifeedService();
  final OmnifeedFeedCommentService _feedComments = OmnifeedFeedCommentService();
  final commentCtrl = TextEditingController();
  final commentFocus = FocusNode();
  final replyDraft = FeedCommentReplyDraft();

  final item = Rxn<OmnifeedItem>();
  final comments = <OmnifeedComment>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;
  final commentsErrorMessage = ''.obs;
  final highlightCommentId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    item.value = initialItem;
    _load();
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    commentFocus.dispose();
    super.onClose();
  }

  List<FeedNestedCommentData> nestedComments() {
    final mapped = mapOmnifeedCommentsToNested(comments);
    return [
      for (final comment in mapped)
        comment.copyWith(
          onLike: (reactionId) => reactToComment(
            commentId: comment.id,
            reactionId: reactionId,
          ),
        ),
    ];
  }

  void beginReply(FeedNestedCommentData comment) {
    replyDraft.beginFrom(comment);
    replyDraft.primeComposer(commentCtrl);
    requestCommentFocusAfterFrame(commentFocus);
  }

  void cancelReply() {
    replyDraft.clear();
    commentCtrl.clear();
  }

  Future<void> sendFromBar() async {
    if (replyDraft.isActive) {
      await sendReply(
        parentCommentId: replyDraft.parentCommentId!,
        message: replyDraft.messageForApi(commentCtrl.text),
      );
    } else {
      await sendComment();
    }
  }

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = '';
    commentsErrorMessage.value = '';
    try {
      try {
        final detail = await _service.fetchItemDetail(initialItem.itemId);
        item.value = detail.mergedWith(initialItem);
      } on OmnifeedException catch (e) {
        item.value ??= initialItem;
        errorMessage.value = e.message;
      } on DioException catch (e) {
        item.value ??= initialItem;
        errorMessage.value = XenforoApi.connectionMessage(e);
      } catch (_) {
        item.value ??= initialItem;
      }

      try {
        final page = await _service.fetchComments(
          initialItem.itemId,
          profilePostId: initialItem.contentType == 'profile_post'
              ? initialItem.contentId
              : null,
        );
        comments.value = page.comments;
      } on OmnifeedException catch (e) {
        commentsErrorMessage.value = e.message;
      } on DioException catch (e) {
        commentsErrorMessage.value =
            'Commenti non disponibili. ${XenforoApi.connectionMessage(e)}';
      } catch (_) {
        commentsErrorMessage.value = 'Commenti non disponibili.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendComment() async {
    final text = commentCtrl.text.trim();
    if (text.isEmpty) return;
    isSending.value = true;
    try {
      await _service.postComment(itemId: initialItem.itemId, message: text);
      commentCtrl.clear();
      await _load();
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendReply({
    required int parentCommentId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    final beforeIds = comments.map((c) => c.commentId).toList();
    isSending.value = true;
    try {
      await _service.postComment(
        itemId: initialItem.itemId,
        message: message.trim(),
        parentCommentId: parentCommentId,
      );
      replyDraft.clear();
      commentCtrl.clear();
      await _load();
      highlightCommentId.value = detectNewNestedCommentId(
        previousIds: beforeIds,
        current: nestedComments(),
        parentCommentId: parentCommentId,
      );
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> react({int reactionId = 1}) async {
    final current = item.value ?? initialItem;
    try {
      final action =
          await _service.reactToItem(item: current, reactionId: reactionId);
      final delta = action == 'delete' ? -1 : 1;
      final score = current.reactionScore + delta;
      item.value = current.copyWith(reactionScore: score < 0 ? 0 : score);
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await _load();
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  Future<void> toggleBookmark() async {
    final current = item.value ?? initialItem;
    try {
      final bookmarked = await _service.toggleBookmark(current);
      item.value = current.copyWith(isBookmarked: bookmarked);
      AppToast.success(bookmarked ? 'Salvato.' : 'Rimosso dai salvati.');
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  void applyShareResult(FeedShareApiResult result) {
    final current = item.value ?? initialItem;
    item.value = current.copyWith(shareCount: result.shareCount);
  }

  Future<void> reactToComment({
    required int commentId,
    int reactionId = 1,
  }) async {
    final current = item.value ?? initialItem;
    try {
      await _feedComments.reactComment(
        item: current,
        commentId: commentId,
        reactionId: reactionId,
      );
      await _load();
    } on ReactionException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      AppToast.error('Impossibile reagire al commento.');
    }
  }
}
