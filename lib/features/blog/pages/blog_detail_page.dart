import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_comment.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/blog/widgets/blog_entry_body.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage({super.key, required this.entryId});

  final int entryId;

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final BlogService _service = BlogService();
  final _commentCtrl = TextEditingController();
  BlogEntry? _entry;
  List<BlogComment> _comments = const [];
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
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entry = await _service
          .fetchEntry(widget.entryId)
          .timeout(const Duration(seconds: 25));
      final commentsPage = await _service.fetchComments(widget.entryId);
      if (!mounted) return;
      setState(() {
        _entry = entry;
        _comments = commentsPage.comments;
        _loading = false;
      });
    } on TimeoutException {
      _fail('Il caricamento impiega troppo tempo. Riprova.');
    } on BlogException catch (e) {
      _fail(e.message);
    } on DioException catch (e) {
      _fail(XenforoApi.connectionMessage(e));
    } catch (_) {
      _fail('Impossibile caricare il blogpost.');
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
    final entry = _entry;
    if (entry == null) return;
    try {
      final action = await _service.react(
        blogEntryId: entry.blogEntryId,
        authorUserId: entry.author?.userId,
        reactionId: reactionId,
      );
      if (!mounted) return;
      final delta = action == 'delete' ? -1 : 1;
      final score = entry.reactionScore + delta;
      setState(() {
        _entry = BlogEntry(
          blogEntryId: entry.blogEntryId,
          title: entry.title,
          messagePlainText: entry.messagePlainText,
          messageParsed: entry.messageParsed,
          postDate: entry.postDate,
          commentCount: entry.commentCount,
          reactionScore: score < 0 ? 0 : score,
          canReact: entry.canReact,
          canComment: entry.canComment,
          author: entry.author,
          blog: entry.blog,
          category: entry.category,
          tags: entry.tags,
          coverImage: entry.coverImage,
          attachments: entry.attachments,
          viewUrl: entry.viewUrl,
        );
      });
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await _load();
    } on BlogException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  Future<void> _reactToComment(BlogComment comment, {int reactionId = 1}) async {
    try {
      await _service.reactToComment(
        commentId: comment.commentId,
        authorUserId: comment.author?.userId,
        reactionId: reactionId,
      );
      await _load();
    } on BlogException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _entry == null) return;
    setState(() => _sending = true);
    try {
      await _service.postComment(
        blogEntryId: widget.entryId,
        message: text,
      );
      _commentCtrl.clear();
      await _load();
    } on BlogException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openBlogFilter() {
    final entry = _entry;
    if (entry == null) return;
    final blogId = entry.blog?.blogId;
    if (blogId == null || blogId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterBlogId: blogId,
        pageTitle: entry.blog?.title ?? 'Blog',
      ),
    );
  }

  void _openCategoryFilter() {
    final entry = _entry;
    if (entry == null) return;
    final categoryId = entry.category?.categoryId;
    if (categoryId == null || categoryId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterCategoryId: categoryId,
        pageTitle: entry.category?.title ?? 'Categoria',
      ),
    );
  }

  void _focusCommentInput() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  String _blogMetaDateLine(BlogEntry entry) {
    final date = formatOmnifeedCardDate(entry.postDate);
    final category = entry.category?.title ?? '';
    if (category.isEmpty) return date;
    return '$date - $category';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Blog'),
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
              : _entry == null
                  ? const SizedBox.shrink()
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
                                    avatarUrl: _entry!.author?.avatarUrl,
                                    authorName: _entry!.author?.username ??
                                        _entry!.author?.label,
                                    moduleLabel: _entry!.blog?.title,
                                    dateLabel: _blogMetaDateLine(_entry!),
                                    onModuleTap: _openBlogFilter,
                                  ),
                                  body: BlogEntryBody(entry: _entry!),
                                  beforeFooter: _entry!.tags.isNotEmpty
                                      ? FeedCardTagsRow(
                                          tags: _entry!.tags,
                                          onTagTap: TagFeedNavigation.openTag,
                                        )
                                      : null,
                                  footer: FeedCardActionBar(
                                    commentCount: _entry!.commentCount,
                                    likeCount: _entry!.reactionScore,
                                    visitorReactionId: _entry!.visitorReactionId,
                                    onComment: _focusCommentInput,
                                    onReact: _entry!.canReact
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
                                          message: comment.messagePlainText,
                                          messageHtml: comment.messageParsed,
                                          likeCount: comment.reactionScore,
                                          visitorReactionId:
                                              comment.visitorReactionId,
                                          showCommentButton: false,
                                          onLike: comment.canReact
                                              ? (reactionId) =>
                                                  _reactToComment(
                                                    comment,
                                                    reactionId: reactionId,
                                                  )
                                              : null,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_entry!.canComment) _CommentBar(
                          controller: _commentCtrl,
                          isSending: _sending,
                          onSend: _sendComment,
                        ),
                      ],
                    ),
    );
  }
}

class _CommentBar extends StatelessWidget {
  const _CommentBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Scrivi un commento…',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, color: AppTheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
