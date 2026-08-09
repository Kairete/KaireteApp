import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_author_signature.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_link_preview.dart';
import 'package:kairete/features/media/utils/media_navigation.dart';
import 'package:kairete/features/media/widgets/media_thumbnail.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Card feed in stile app legacy (screenshot Kairete).
class OmnifeedCard extends StatelessWidget {
  const OmnifeedCard({
    super.key,
    required this.item,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onBookmark,
    this.onShareInternal,
    this.onShareExternal,
    this.onAuthorTap,
    this.onBlogTap,
    this.onForumTap,
    this.onGroupTap,
    this.onMediaTap,
    this.onMediaCategoryTap,
    this.onFollow,
    this.onEdit,
    this.onDelete,
    this.onHighlight,
    this.onTagTap,
    this.showOwnerActions = false,
    this.expandBody = false,
    this.comments = const [],
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final Future<void> Function()? onBookmark;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onGroupTap;
  final VoidCallback? onMediaTap;
  final VoidCallback? onMediaCategoryTap;
  final VoidCallback? onFollow;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHighlight;
  final void Function(String tag)? onTagTap;
  final bool showOwnerActions;
  final bool expandBody;
  final List<Widget> comments;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final isSocialNews = item.contentType == 'social_news_article';
    final isMedia = item.contentType == 'xfmg_media';
    final isBlog = item.contentType == 'ubs_blog_entry';
    final isGroupPost = item.contentType == 'tl_group_post';
    final isThread = item.contentType == 'thread';
    final date = formatOmnifeedCardDate(item.itemDate);
    final nickname = isMedia && author?.username.trim().isNotEmpty == true
        ? author!.username
        : (author?.label ?? author?.username);
    final moduleLabel = isSocialNews || item.sharedItem != null
        ? null
        : item.headerModuleLabel;
    final headerTitle = isSocialNews
        ? (item.categoryLabel?.trim().isNotEmpty == true
            ? item.categoryLabel!.trim()
            : (item.contentTitle?.trim().isNotEmpty == true
                ? item.contentTitle!.trim()
                : 'News'))
        : nickname;
    final showFollow = onFollow != null &&
        !showOwnerActions &&
        !isSocialNews &&
        item.sharedItem == null &&
        (moduleLabel == null || moduleLabel.trim().isEmpty);

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: isSocialNews ? null : author?.avatarUrl,
        authorName: headerTitle,
        moduleLabel: moduleLabel,
        activityLabel: item.sharedItem != null ? ' ha condiviso un post' : null,
        followLabel: showFollow ? 'Segui' : null,
        dateLabel: date,
        categoryLabel: isSocialNews ||
                isMedia ||
                isGroupPost ||
                isThread
            ? null
            : item.categoryLabel,
        onAuthorTap: onAuthorTap,
        onFollowTap: showFollow ? onFollow : null,
        onModuleTap: item.sharedItem != null
            ? null
            : (isMedia ? onMediaTap : _moduleTap()),
        onCategoryTap: isMedia ? null : onMediaCategoryTap,
        trailing: _trailingMenu(),
      ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMedia
                  ? _mediaBody()
                  : isBlog
                      ? _blogBody()
                      : isSocialNews
                          ? _socialNewsBody()
                          : _defaultBody(),
              if (item.sharedItem != null) ...[
                const SizedBox(height: 10),
                _SharedOriginalPreview(original: item.sharedItem!),
              ],
              FeedCardTagsContinueRow(
                tags: item.tags,
                onTagTap: onTagTap,
                onContinue: onOpen,
                showContinue:
                    !expandBody && item.listPreviewNeedsDetailLink,
                continueLabel: item.continueLabel ?? 'Continua',
                embeddedInBody: true,
              ),
            ],
          ),
        ),
      ),
      beforeFooter: FeedAuthorSignature.maybe(
        html: author?.signatureHtml,
        plain: author?.signaturePlain,
        show: author?.contentShowSignature ?? true,
      ),
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        likeCount: item.reactionScore,
        visitorReactionId: item.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
        isBookmarked: item.isBookmarked,
        onBookmark: onBookmark,
        shareCount: item.shareCount,
        onShareInternal: onShareInternal,
        onShareExternal: onShareExternal,
      ),
      comments: comments,
    );
  }

  VoidCallback? _moduleTap() {
    if (item.contentType == 'ubs_blog_entry') return onBlogTap;
    if (item.contentType == 'thread') return onForumTap;
    if (item.contentType == 'tl_group_post') return onGroupTap;
    if (item.contentType == 'xfmg_media') return onMediaTap;
    return null;
  }

  Widget _trailingMenu() {
    final showMenu = (showOwnerActions && (onEdit != null || onDelete != null)) ||
        onHighlight != null;
    if (!showMenu) {
      return item.isHighlighted
          ? const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.push_pin, size: 16, color: Color(0xFFB45309)),
            )
          : const FeedCardMenuButton();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.isHighlighted)
          const Padding(
            padding: EdgeInsets.only(right: 2),
            child: Icon(Icons.push_pin, size: 16, color: Color(0xFFB45309)),
          ),
        FeedCardOwnerMenu(
          onEdit: showOwnerActions ? onEdit : null,
          onDelete: showOwnerActions ? onDelete : null,
          onHighlight: onHighlight,
          isHighlighted: item.isHighlighted,
        ),
      ],
    );
  }

  Widget _blogBody() {
    final title = item.moduleTitle;
    final cover = item.blogCoverUrl;
    final body = item.listPreviewBody;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        if (cover != null && cover.isNotEmpty) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: cover,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ],
        if (item.linkPreviews.isNotEmpty) ...[
          const SizedBox(height: 10),
          FeedLinkPreview(previews: item.linkPreviews),
        ],
      ],
    );
  }

  Widget _socialNewsBody() {
    final title = item.moduleTitle;
    final html = item.messageParsed?.trim();
    final hasHtml = html != null &&
        html.isNotEmpty &&
        RegExp(r'<[^>]+>').hasMatch(html);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 132,
            width: double.infinity,
            child: item.mediaThumbnailUrl?.trim().isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: item.mediaThumbnailUrl!,
                    width: double.infinity,
                    height: 132,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: item.socialNewsHeroColor,
                    ),
                  )
                : Container(
                    height: 132,
                    width: double.infinity,
                    color: item.socialNewsHeroColor,
                  ),
          ),
        ),
        if (expandBody && hasHtml) ...[
          const SizedBox(height: 8),
          Html(data: html),
        ] else if (_socialNewsPreviewText().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _socialNewsPreviewText(),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  String _socialNewsPreviewText() {
    if (expandBody) return item.displayBody;
    return item.listPreviewBody;
  }

  Widget _defaultBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.showsModuleTitle) ...[
          Text(
            item.moduleTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandAccent,
            ),
          ),
          if (item.listPreviewBody.isNotEmpty) const SizedBox(height: 6),
        ],
        if (item.listPreviewBody.isNotEmpty)
          Text(
            item.listPreviewBody,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        if (item.imageAttachmentUrls.isNotEmpty) ...[
          const SizedBox(height: 10),
          FeedCardFullWidthImages(
            imageUrls: item.imageAttachmentUrls,
            onTap: onOpen,
          ),
        ],
        if (item.linkPreviews.isNotEmpty) ...[
          const SizedBox(height: 10),
          FeedLinkPreview(previews: item.linkPreviews),
        ],
      ],
    );
  }

  Widget _mediaBody() {
    final preview = item.toMediaPreview();
    final body = item.listPreviewBody;
    final title = item.moduleTitle;
    void openViewer() => MediaNavigation.openViewer(preview);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandAccent,
            ),
          ),
        if (preview.heroImageUrl != null || preview.isPlayable) ...[
          const SizedBox(height: 8),
          MediaThumbnail(
            item: preview,
            onTap: preview.isPlayable ? openViewer : onOpen,
          ),
        ],
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _SharedOriginalPreview extends StatelessWidget {
  const _SharedOriginalPreview({required this.original});

  final OmnifeedItem original;

  @override
  Widget build(BuildContext context) {
    final author = original.author;
    final name = author?.label ?? author?.username ?? '';
    final body = original.listPreviewBody;
    final title = original.moduleTitle;
    final typeLabel = switch (original.resolvedContentType) {
      'thread' => 'Discussione',
      'ubs_blog_entry' => 'Blog',
      'xfmg_media' => 'Media',
      'tl_group_post' => 'Gruppo',
      'profile_post' => 'Post',
      _ => '',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        color: const Color(0xFFFAFAFA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FeedCardAvatar(
                url: author?.avatarUrl,
                name: name,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.authorName,
                        ),
                      ),
                    if (typeLabel.isNotEmpty)
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (title.isNotEmpty && !original.isPlainFeedPost) ...[
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
          if ((original.mediaThumbnailUrl ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: original.mediaThumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFEEEEEE),
                  ),
                ),
              ),
            ),
          ],
          if (body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
