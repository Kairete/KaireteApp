import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/album_create_page.dart';
import 'package:kairete/features/media/pages/media_compose_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/media/utils/media_navigation.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/media/widgets/media_viewer.dart';
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
  MediaItem? _item;
  List<MediaComment> _comments = const [];
  bool _loading = true;
  bool _sending = false;
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
                                    .openUserProfile(_item!.author?.userId),
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
                              ),
                              comments: _comments
                                  .map(
                                    (comment) => FeedCommentTile(
                                      authorName: comment.author?.label ??
                                          comment.author?.username ??
                                          '',
                                      avatarUrl: comment.author?.avatarUrl,
                                      dateLabel: formatOmnifeedCardDate(
                                        comment.commentDate,
                                      ),
                                      message:
                                          comment.messagePlainText ?? '',
                                      likeCount: comment.reactionScore,
                                      visitorReactionId:
                                          comment.visitorReactionId,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FeedCommentBar(
                      controller: _commentCtrl,
                      focusNode: _commentFocus,
                      isSending: _sending,
                      onSend: _sendComment,
                    ),
                  ],
                ),
    );
  }
}
