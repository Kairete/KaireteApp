import 'package:flutter/material.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_feed_comment_service.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

/// Commenti nidificati inline nelle card del newsfeed.
class OmnifeedFeedComments extends StatefulWidget {
  const OmnifeedFeedComments({
    super.key,
    required this.item,
    this.onChanged,
  });

  final OmnifeedItem item;
  final VoidCallback? onChanged;

  @override
  State<OmnifeedFeedComments> createState() => OmnifeedFeedCommentsState();
}

class OmnifeedFeedCommentsState extends State<OmnifeedFeedComments> {
  final OmnifeedFeedCommentService _comments = OmnifeedFeedCommentService();
  final ForumService _forum = ForumService();
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();
  final _replyDraft = FeedCommentReplyDraft();

  List<FeedNestedCommentData> _nested = const [];
  bool _loading = false;
  bool _sending = false;
  bool _pageComposerActive = false;
  int? _highlightCommentId;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // I commenti restano chiusi finché l'utente non tocca la nuvoletta nel footer.
  }

  @override
  void didUpdateWidget(covariant OmnifeedFeedComments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      _deactivatePageComposer();
      _replyDraft.clear();
      _commentCtrl.clear();
      _nested = const [];
      _expanded = false;
    } else if (_expanded &&
        widget.item.commentCount != oldWidget.item.commentCount &&
        widget.item.supportsInlineFeedComments &&
        !_loading) {
      // Già aperti: aggiorna la lista se cambia il conteggio.
      _load();
    }
  }

  @override
  void dispose() {
    FeedInlineReplyHost.hide(widget.item.itemId);
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void focusComposer() {
    expandAndLoad();
    if (_replyDraft.isActive) {
      _replyDraft.clear();
      _commentCtrl.clear();
    }
    _activatePageComposer(focus: true);
  }

  void _activatePageComposer({bool focus = false}) {
    _pageComposerActive = true;
    _syncPageComposerBar();
    if (focus) {
      requestCommentFocusAfterFrame(_commentFocus, mountedOn: this);
    }
    if (mounted) setState(() {});
  }

  void _deactivatePageComposer() {
    _pageComposerActive = false;
    FeedInlineReplyHost.hide(widget.item.itemId);
    if (mounted) setState(() {});
  }

  String get _hintText => widget.item.resolvedContentType == 'thread'
      ? 'Scrivi una risposta…'
      : 'Scrivi un commento…';

  FeedInlineReplyState _pageComposerState() {
    return FeedInlineReplyState(
      ownerId: widget.item.itemId,
      replyDraft: _replyDraft,
      controller: _commentCtrl,
      focusNode: _commentFocus,
      isSending: _sending,
      hintText: _hintText,
      onSend: _sendFromComposer,
      onCancel: _replyDraft.isActive ? _cancelReply : _deactivatePageComposer,
    );
  }

  void _syncPageComposerBar() {
    if (!_pageComposerActive) {
      FeedInlineReplyHost.hide(widget.item.itemId);
      return;
    }
    final state = _pageComposerState();
    if (FeedInlineReplyHost.active.value?.ownerId == widget.item.itemId) {
      FeedInlineReplyHost.update(state);
    } else {
      FeedInlineReplyHost.show(state);
    }
  }

  void _beginReply(FeedNestedCommentData comment) {
    expandAndLoad();
    _replyDraft.beginFrom(comment);
    _replyDraft.primeComposer(_commentCtrl);
    _activatePageComposer(focus: true);
  }

  void _cancelReply() {
    _replyDraft.clear();
    _commentCtrl.clear();
    if (_pageComposerActive) {
      _syncPageComposerBar();
    } else {
      FeedInlineReplyHost.hide(widget.item.itemId);
    }
    if (mounted) setState(() {});
  }

  Future<void> _sendFromComposer() async {
    if (_replyDraft.isActive) {
      await _sendReply(
        _replyDraft.parentCommentId!,
        _replyDraft.messageForApi(_commentCtrl.text),
      );
    } else {
      await _sendTopLevelComment();
    }
  }

  void expandAndLoad() {
    if (!_expanded) {
      setState(() => _expanded = true);
    }
    if (_nested.isEmpty && !_loading) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!widget.item.supportsInlineFeedComments) return;
    setState(() => _loading = true);
    try {
      final nested = await _comments.load(widget.item);
      if (!mounted) return;
      setState(() => _nested = _withLikeReload(nested));
    } on OmnifeedException catch (e) {
      if (mounted) AppToast.error(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _nested = const []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FeedNestedCommentData> _withLikeReload(
    List<FeedNestedCommentData> comments,
  ) {
    return [
      for (final comment in comments)
        comment.copyWith(
          onLike: comment.onLike == null
              ? null
              : (reactionId) => _reactToComment(comment, reactionId),
          clearOnLike: comment.onLike == null,
        ),
    ];
  }

  Future<void> _reactToComment(
    FeedNestedCommentData comment,
    int reactionId,
  ) async {
    try {
      await _comments.reactComment(
        item: widget.item,
        commentId: comment.id,
        reactionId: reactionId,
      );
      await _load();
      widget.onChanged?.call();
    } on ReactionException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      AppToast.error('Impossibile reagire al commento.');
    }
  }

  Future<void> _sendTopLevelComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _comments.post(item: widget.item, message: text);
      _commentCtrl.clear();
      _expanded = true;
      await _load();
      widget.onChanged?.call();
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } catch (e) {
      AppToast.error('Impossibile inviare il commento.');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _syncPageComposerBar();
      }
    }
  }

  Future<void> _sendReply(int parentId, String message) async {
    if (message.trim().isEmpty) return;
    final beforeIds = _nested.map((c) => c.id).toList();
    setState(() => _sending = true);
    _syncPageComposerBar();
    try {
      if (widget.item.resolvedContentType == 'thread') {
        await postForumFeedReply(
          forum: _forum,
          threadId: widget.item.nativeContentId,
          parentPostId: parentId,
          message: message,
        );
      } else {
        FeedNestedCommentData? quoted;
        for (final comment in _nested) {
          if (comment.id == parentId) {
            quoted = comment;
            break;
          }
        }
        await _comments.post(
          item: widget.item,
          message: message,
          parentCommentId: parentId,
          parentPostId: parentId,
          quotedAuthorName: quoted?.authorName,
        );
      }
      _replyDraft.clear();
      _commentCtrl.clear();
      await _load();
      if (!mounted) return;
      setState(() {
        _highlightCommentId = detectNewNestedCommentId(
          previousIds: beforeIds,
          current: _nested,
          parentCommentId: parentId,
        );
      });
      widget.onChanged?.call();
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } catch (_) {
      AppToast.error('Impossibile inviare la risposta.');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _syncPageComposerBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.item.supportsInlineFeedComments || !_expanded) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading && _nested.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_nested.isEmpty && widget.item.commentCount > 0 && !_loading)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Nessun commento caricato.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          )
        else
          FeedNestedCommentThread(
            comments: _nested,
            highlightCommentId: _highlightCommentId,
            onReplyTap: _beginReply,
          ),
        if (!_pageComposerActive)
          InkWell(
            onTap: focusComposer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Text(
                _hintText,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ),
      ],
    );
  }
}
