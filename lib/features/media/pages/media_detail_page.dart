import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/media/utils/media_comment_ui.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/album_create_page.dart';
import 'package:kairete/features/media/pages/media_compose_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/media/utils/media_navigation.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/media/widgets/media_viewer.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class MediaDetailPage extends StatefulWidget {
  const MediaDetailPage({super.key, required this.mediaId});

  final int mediaId;

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  final MediaService _service = MediaService();
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();
  final _replyDraft = FeedCommentReplyDraft();
  MediaItem? _item;
  List<MediaComment> _comments = const [];
  int _shareCount = 0;
  bool _loading = true;
  bool _sending = false;
  int? _highlightCommentId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await _service
          .fetchMediaItem(widget.mediaId)
          .timeout(const Duration(seconds: 25));
      final commentsPage = await _service.fetchComments(widget.mediaId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _comments = commentsPage.comments;
        _loading = false;
      });
    } on TimeoutException {
      _fail('Il caricamento impiega troppo tempo. Riprova.');
    } on MediaException catch (e) {
      _fail(e.message);
    } on DioException catch (e) {
      _fail(XenforoApi.connectionMessage(e));
    } catch (_) {
      _fail('Impossibile caricare il media.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  Future<void> _react({int reactionId = 1}) async {
    final item = _item;
    if (item == null) return;
    try {
      await _service.react(
        mediaId: item.mediaId,
        authorUserId: item.author?.userId,
        reactionId: reactionId,
      );
      await _load();
      AppToast.success('Reazione inviata.');
    } on MediaException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  List<FeedNestedCommentData> _nestedComments() {
    return [
      for (final comment in mapMediaCommentsToNested(_comments))
        comment.copyWith(
          onLike: (reactionId) => _reactToComment(
            commentId: comment.id,
            reactionId: reactionId,
          ),
        ),
    ];
  }

  Future<void> _reactToComment({
    required int commentId,
    int reactionId = 1,
  }) async {
    try {
      await ReactionService().reactMediaComment(
        commentId,
        reactionId: reactionId,
      );
      await _load();
    } on ReactionException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      AppToast.error('Impossibile reagire al commento.');
    }
  }

  Future<void> _sendFromBar() async {
    if (_replyDraft.isActive) {
      await _sendReply(_replyDraft.parentCommentId!, _replyDraft.messageForApi(_commentCtrl.text));
    } else {
      await _sendComment();
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _service.postComment(mediaId: widget.mediaId, message: text);
      _commentCtrl.clear();
      await _load();
    } on MediaException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendReply(int parentCommentId, String message) async {
    if (message.trim().isEmpty) return;
    final beforeIds = _comments.map((c) => c.commentId).toList();
    setState(() => _sending = true);
    try {
      MediaComment? quoted;
      for (final comment in _comments) {
        if (comment.commentId == parentCommentId) {
          quoted = comment;
          break;
        }
      }
      await _service.postComment(
        mediaId: widget.mediaId,
        message: message.trim(),
        parentCommentId: parentCommentId,
        quotedAuthorName: quoted?.author?.label ?? quoted?.author?.username,
        quotedAuthorUserId: quoted?.author?.userId ?? 0,
      );
      _replyDraft.clear();
      _commentCtrl.clear();
      await _load();
      if (!mounted) return;
      setState(() {
        _highlightCommentId = detectNewNestedCommentId(
          previousIds: beforeIds,
          current: _nestedComments(),
          parentCommentId: parentCommentId,
        );
      });
    } on MediaException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _beginReply(FeedNestedCommentData comment) {
    _replyDraft.beginFrom(comment);
    _replyDraft.primeComposer(_commentCtrl);
    setState(() {});
    requestCommentFocusAfterFrame(_commentFocus, mountedOn: this);
  }

  void _cancelReply() {
    _replyDraft.clear();
    _commentCtrl.clear();
    setState(() {});
  }

  void _openViewer() {
    final item = _item;
    if (item == null) return;
    MediaNavigation.openViewer(item);
  }

  void _openAlbumFilter() {
    final item = _item;
    if (item == null) return;
    final albumId = item.album?.albumId;
    if (albumId == null || albumId <= 0) return;
    Get.to(
      () => MediaListPage(
        filterAlbumId: albumId,
        pageTitle: item.album?.title ?? 'Album',
      ),
    );
  }

  void _openCategoryFilter() {
    final item = _item;
    if (item == null) return;
    final categoryId = item.category?.categoryId;
    if (categoryId == null || categoryId <= 0) return;
    Get.to(
      () => MediaListPage(
        filterCategoryId: categoryId,
        pageTitle: item.category?.title ?? 'Categoria',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Media'),
        actions: [
          IconButton(
            tooltip: 'Aggiungi media',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () async {
              await Get.to(() => const MediaComposePage());
            },
          ),
          IconButton(
            tooltip: 'Crea album',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () async {
              final created = await Get.to<bool>(() => const AlbumCreatePage());
              if (created == true) await _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 8),
                          children: [
                            FeedCardShell(
                              header: FeedCardAuthorHeader(
                                avatarUrl: _item!.author?.avatarUrl,
                                authorName: _item!.author?.label ??
                                    _item!.author?.username,
                                moduleLabel: _item!.albumHeaderLabel,
                                dateLabel:
                                    formatOmnifeedCardDate(_item!.mediaDate),
                                categoryLabel: _item!.category?.title,
                                onAuthorTap: () => OmnifeedNavigation
                                    .openUserProfile(
                                  _item!.author?.userId,
                                  username: _item!.author?.username,
                                ),
                                onModuleTap: _openAlbumFilter,
                                onCategoryTap: _openCategoryFilter,
                              ),
                              body: MediaDetailBody(
                                item: _item!,
                                onThumbnailTap: _openViewer,
                              ),
                              beforeFooter: _item!.tags.isNotEmpty
                                  ? FeedCardTagsRow(
                                      tags: _item!.tags,
                                      onTagTap: TagFeedNavigation.openTag,
                                    )
                                  : null,
                              footer: FeedCardActionBar(
                                commentCount: _item!.commentCount,
                                likeCount: _item!.reactionScore,
                                visitorReactionId: _item!.visitorReactionId,
                                onComment: () {},
                                onReact: _item!.canReact
                                    ? (reactionId) =>
                                        _react(reactionId: reactionId)
                                    : null,
                                shareCount: _shareCount,
                                onShareInternal: () async {
                                  final item = _item!;
                                  final result = await showFeedShareInternal(
                                    context: context,
                                    itemId: OmnifeedItemId.encode(
                                      OmnifeedItemId.typeMedia,
                                      item.mediaId,
                                    ),
                                    previewText:
                                        item.description ?? item.title,
                                  );
                                  if (result != null && mounted) {
                                    setState(() {
                                      _shareCount = result.shareCount;
                                    });
                                  }
                                },
                                onShareExternal: () async {
                                  final item = _item!;
                                  final result = await showFeedShareExternal(
                                    context: context,
                                    itemId: OmnifeedItemId.encode(
                                      OmnifeedItemId.typeMedia,
                                      item.mediaId,
                                    ),
                                    viewUrl: item.viewUrl,
                                  );
                                  if (result != null && mounted) {
                                    setState(() {
                                      _shareCount = result.shareCount;
                                    });
                                  }
                                },
                              ),
                              comments: [
                                FeedNestedCommentThread(
                                  comments: _nestedComments(),
                                  highlightCommentId: _highlightCommentId,
                                  onReplyTap: _beginReply,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    FeedCommentBar(
                      controller: _commentCtrl,
                      focusNode: _commentFocus,
                      isSending: _sending,
                      onSend: _sendFromBar,
                      replyLabel: _replyDraft.replyLabel,
                      onCancelReply:
                          _replyDraft.isActive ? _cancelReply : null,
                    ),
                  ],
                ),
    );
  }
}
