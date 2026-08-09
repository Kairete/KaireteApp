import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/utils/content_edit_helper.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_comment.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/pages/blog_compose_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/blog/widgets/blog_entry_body.dart';
import 'package:kairete/features/blog/widgets/blog_related_carousel.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
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
  final _commentFocus = FocusNode();
  final _replyDraft = FeedCommentReplyDraft();
  BlogEntry? _entry;
  List<BlogComment> _comments = const [];
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
          canEdit: entry.canEdit,
          canDelete: entry.canDelete,
          visitorReactionId: entry.visitorReactionId,
          author: entry.author,
          blog: entry.blog,
          category: entry.category,
          tags: entry.tags,
          coverImage: entry.coverImage,
          attachments: entry.attachments,
          viewUrl: entry.viewUrl,
          previewHasMore: entry.previewHasMore,
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

  Future<void> _sendFromBar() async {
    if (_replyDraft.isActive) {
      await _sendReply(_replyDraft.parentCommentId!, _replyDraft.messageForApi(_commentCtrl.text));
    } else {
      await _sendComment();
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

  Future<void> _sendReply(int parentCommentId, String message) async {
    if (message.trim().isEmpty || _entry == null) return;
    final beforeIds = _comments.map((c) => c.commentId).toList();
    setState(() => _sending = true);
    try {
      await _service.postComment(
        blogEntryId: widget.entryId,
        message: message.trim(),
        parentCommentId: parentCommentId,
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
    } on BlogException catch (e) {
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

  List<FeedNestedCommentData> _nestedComments() {
    final ids = _comments.map((c) => c.commentId).toList();
    final parents = _comments.map((c) => c.parentCommentId).toList();
    final depths = depthByCommentId(ids: ids, parentIds: parents);
    return _comments
        .map(
          (comment) {
            final depth = depths[comment.commentId] ?? 0;
            return FeedNestedCommentData(
              id: comment.commentId,
              parentId: comment.parentCommentId,
              depthHint: depth,
              authorName:
                  comment.author?.label ?? comment.author?.username ?? '',
              avatarUrl: comment.author?.avatarUrl,
              dateLabel: formatFeedCommentDate(comment.commentDate),
              message: comment.messagePlainText,
              messageHtml: comment.messageParsed,
              likeCount: comment.reactionScore,
              visitorReactionId: comment.visitorReactionId,
              canReply: nestedCommentCanReply(depth),
              canLike: comment.canReact,
              onLike: comment.canReact
                  ? (reactionId) =>
                      _reactToComment(comment, reactionId: reactionId)
                  : null,
            );
          },
        )
        .toList();
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

  void _focusCommentInput() {
    _cancelReply();
    _commentFocus.requestFocus();
  }

  Future<void> _editEntry() async {
    final entry = _entry;
    if (entry == null || !entry.canEdit) return;
    final updated = await Get.to<bool>(
      () => BlogComposePage(editEntryId: entry.blogEntryId),
    );
    if (updated == true) await _load();
  }

  Future<void> _deleteEntry() async {
    final entry = _entry;
    if (entry == null || !entry.canDelete) return;
    if (!await confirmDeleteContent(context)) return;
    try {
      await _service.deleteEntry(entry.blogEntryId);
      AppToast.success('Articolo eliminato.');
      if (mounted) Get.back();
    } on BlogException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile eliminare l\'articolo.');
    }
  }

  Future<void> _toggleHighlight() async {
    final entry = _entry;
    if (entry == null) return;
    final blogId = entry.blog?.blogId ?? 0;
    final scope = (entry.highlightScope ?? '').trim().isNotEmpty
        ? entry.highlightScope!.trim()
        : (blogId > 0 ? 'owner:blog:$blogId' : 'admin:blog');
    try {
      final item = OmnifeedItem(
        itemId: OmnifeedItemId.encode(
          OmnifeedItemId.typeBlogPost,
          entry.blogEntryId,
        ),
        contentType: 'ubs_blog_entry',
        contentId: entry.blogEntryId,
        canHighlight: true,
        isHighlighted: entry.isHighlighted,
        highlightScope: scope,
      );
      final highlighted = await OmnifeedService().toggleHighlight(item);
      if (!mounted) return;
      setState(() {
        _entry = entry.copyWith(
          isHighlighted: highlighted,
          canHighlight: true,
          highlightScope: scope,
        );
      });
      AppToast.success(
        highlighted ? 'Fissato in alto sul blog.' : 'Tolto dall\'alto.',
      );
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (_) {
      AppToast.error('Impossibile aggiornare il pin.');
    }
  }

  String _blogMetaDateLine(BlogEntry entry) {
    return formatOmnifeedCardDate(entry.postDate);
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
                                    trailing: _entry!.canEdit ||
                                            _entry!.canDelete ||
                                            _entry!.canHighlight ||
                                            _entry!.isHighlighted
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_entry!.isHighlighted)
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 2),
                                                  child: Icon(
                                                    Icons.push_pin,
                                                    size: 16,
                                                    color: Color(0xFFB45309),
                                                  ),
                                                ),
                                              FeedCardOwnerMenu(
                                                onEdit: _entry!.canEdit
                                                    ? _editEntry
                                                    : null,
                                                onDelete: _entry!.canDelete
                                                    ? _deleteEntry
                                                    : null,
                                                onHighlight: (_entry!
                                                            .canHighlight ||
                                                        _entry!.isHighlighted)
                                                    ? _toggleHighlight
                                                    : null,
                                                isHighlighted:
                                                    _entry!.isHighlighted,
                                              ),
                                            ],
                                          )
                                        : const FeedCardMenuButton(),
                                  ),
                                  body: BlogEntryBody(entry: _entry!),
                                  afterBody: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (_entry!.tags.isNotEmpty)
                                        FeedCardTagsRow(
                                          tags: _entry!.tags,
                                          onTagTap: TagFeedNavigation.openTag,
                                          tightBottom: true,
                                        ),
                                      BlogRelatedCarousel(
                                        entryId: _entry!.blogEntryId,
                                      ),
                                    ],
                                  ),
                                  beforeFooter: null,
                                  footer: FeedCardActionBar(
                                    commentCount: _entry!.commentCount,
                                    likeCount: _entry!.reactionScore,
                                    visitorReactionId: _entry!.visitorReactionId,
                                    onComment: _focusCommentInput,
                                    onReact: _entry!.canReact
                                        ? (reactionId) =>
                                            _react(reactionId: reactionId)
                                        : null,
                                    shareCount: _shareCount,
                                    onShareInternal: () async {
                                      final entry = _entry!;
                                      final result =
                                          await showFeedShareInternal(
                                        context: context,
                                        itemId: OmnifeedItemId.encode(
                                          OmnifeedItemId.typeBlogPost,
                                          entry.blogEntryId,
                                        ),
                                        previewText: entry.messagePlainText ??
                                            entry.title,
                                      );
                                      if (result != null && mounted) {
                                        setState(() {
                                          _shareCount = result.shareCount;
                                        });
                                      }
                                    },
                                    onShareExternal: () async {
                                      final entry = _entry!;
                                      final result =
                                          await showFeedShareExternal(
                                        context: context,
                                        itemId: OmnifeedItemId.encode(
                                          OmnifeedItemId.typeBlogPost,
                                          entry.blogEntryId,
                                        ),
                                        viewUrl: entry.viewUrl,
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
                        if (_entry!.canComment)
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
