import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
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
    this.onAuthorTap,
    this.onBlogTap,
    this.onForumTap,
    this.onMediaTap,
    this.onMediaCategoryTap,
    this.onEdit,
    this.onDelete,
    this.onTagTap,
    this.showOwnerActions = false,
    this.comments = const [],
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onMediaTap;
  final VoidCallback? onMediaCategoryTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String tag)? onTagTap;
  final bool showOwnerActions;
  final List<Widget> comments;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final isMedia = item.contentType == 'xfmg_media';
    final categoryTitle = item.categoryLabel?.trim();
    final date = formatOmnifeedCardDate(item.itemDate);

    return FeedCardShell(
      header: isMedia
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FeedCardAuthorHeader(
                  avatarUrl: author?.avatarUrl,
                  authorName: author?.username ?? author?.label,
                  moduleLabel: item.headerModuleLabel,
                  dateLabel: null,
                  onAuthorTap: onAuthorTap,
                  onModuleTap: onMediaTap,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (categoryTitle != null && categoryTitle.isNotEmpty) ...[
                        const Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        InkWell(
                          onTap: onMediaCategoryTap,
                          child: Text(
                            categoryTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : FeedCardAuthorHeader(
              avatarUrl: author?.avatarUrl,
              authorName: author?.username ?? author?.label,
              moduleLabel: item.headerModuleLabel,
              dateLabel: date,
              onAuthorTap: onAuthorTap,
              onModuleTap: _moduleTap(),
              trailing: showOwnerActions && (onEdit != null || onDelete != null)
                  ? FeedCardOwnerMenu(onEdit: onEdit, onDelete: onDelete)
                  : const FeedCardMenuButton(),
            ),
      body: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: isMedia ? _mediaBody() : _defaultBody(),
        ),
      ),
      beforeFooter: item.tags.isNotEmpty
          ? FeedCardTagsRow(tags: item.tags, onTagTap: onTagTap)
          : null,
      footer: FeedCardActionBar(
        commentCount: item.commentCount,
        likeCount: item.reactionScore,
        visitorReactionId: item.visitorReactionId,
        onComment: onComment ?? onOpen,
        onReact: onReact,
      ),
      comments: comments,
    );
  }

  VoidCallback? _moduleTap() {
    if (item.contentType == 'ubs_blog_entry') return onBlogTap;
    if (item.contentType == 'thread') return onForumTap;
    if (item.contentType == 'xfmg_media') return onMediaTap;
    return null;
  }

  Widget _defaultBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.showsModuleTitle) ...[
          Text(
            item.moduleTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.accent,
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
        FeedCardDetailLink(
          onTap: onOpen,
          visible: item.listPreviewNeedsDetailLink,
        ),
        if (item.imageAttachmentUrls.isNotEmpty) ...[
          const SizedBox(height: 10),
          FeedCardFullWidthImages(
            imageUrls: item.imageAttachmentUrls,
            onTap: onOpen,
          ),
        ],
      ],
    );
  }

  Widget _mediaBody() {
    final hero = item.mediaHeroUrl;
    final body = item.listPreviewBody;
    final title = item.moduleTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.accent,
            ),
          ),
        if (hero != null) ...[
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: hero,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              if (item.isMediaVideo)
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
            ],
          ),
        ],
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            body.length <= 280 ? body : '${body.substring(0, 277).trimRight()}…',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        ],
        FeedCardDetailLink(
          onTap: onOpen,
          visible: item.listPreviewNeedsDetailLink,
        ),
      ],
    );
  }
}
