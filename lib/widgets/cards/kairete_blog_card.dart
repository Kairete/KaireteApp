import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/helper/time.dart';
import 'package:kairete/theme/kairete_theme.dart';

/// Card lista blog (titolo blog in accent, anteprima, thumbnail).
class KaireteBlogCard extends StatelessWidget {
  const KaireteBlogCard({
    super.key,
    required this.authorName,
    required this.title,
    this.blogName,
    this.preview,
    this.avatarUrl,
    this.thumbnailUrl,
    this.dateTimestamp,
    this.commentCount = 0,
    this.likeCount = 0,
    this.onTap,
    this.onTapDetail,
    this.onTapAvatar,
    this.onTapBlogName,
    this.onTapLike,
    this.onTapReply,
  });

  final String authorName;
  final String title;
  final String? blogName;
  final String? preview;
  final String? avatarUrl;
  final String? thumbnailUrl;
  final int? dateTimestamp;
  final int commentCount;
  final int likeCount;
  final VoidCallback? onTap;
  final VoidCallback? onTapDetail;
  final VoidCallback? onTapAvatar;
  final VoidCallback? onTapBlogName;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapReply;

  String get _dateLabel {
    if (dateTimestamp == null || dateTimestamp == 0) return '';
    return TimeManager.instance.getCalendar(timestamp: dateTimestamp!);
  }

  String get _likeLabel {
    if (likeCount <= 0) return 'Mi piace';
    return 'Mi piace ($likeCount)';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? onTapDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onTapAvatar,
                    borderRadius: BorderRadius.circular(20),
                    child: KaireteCacheNetworkImage(
                      url: avatarUrl ?? '',
                      width: 40,
                      height: 40,
                      isCircle: true,
                      nameImage: authorName,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: KaireteTheme.textPrimary,
                          ),
                        ),
                        if (_dateLabel.isNotEmpty)
                          Text(
                            _dateLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: KaireteTheme.textSecondary,
                            ),
                          ),
                        if (blogName != null && blogName!.isNotEmpty)
                          InkWell(
                            onTap: onTapBlogName,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                blogName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: KaireteTheme.accentBlog,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: KaireteTheme.textSecondary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KaireteTheme.textPrimary,
                ),
              ),
            ),
            if (preview != null && preview!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  preview!.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: KaireteTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(KaireteTheme.cardRadius),
                  child: KaireteCacheNetworkImage(url: thumbnailUrl!),
                ),
              ),
            ],
            if (onTapDetail != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTapDetail,
                  child: const Text('Vedi dettaglio'),
                ),
              ),
            Container(
              color: KaireteTheme.footerBackground,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _ActionChip(
                    label: '$commentCount Commenti',
                    icon: Icons.comment_outlined,
                    onTap: onTapReply,
                  ),
                  _ActionChip(
                    label: _likeLabel,
                    icon: Icons.thumb_up_outlined,
                    onTap: onTapLike,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: KaireteTheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KaireteTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
