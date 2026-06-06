import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Card feed in stile app legacy (screenshot Kairete).
///
/// Struttura per ogni post:
/// - HEADER grigio: avatar + autore + data
/// - BODY bianco: titolo + testo
/// - FOOTER grigio: commenti + like
class OmnifeedCard extends StatelessWidget {
  const OmnifeedCard({
    super.key,
    required this.item,
    this.onOpen,
    this.onComment,
    this.onReact,
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  static const _sectionDivider = Divider(
    height: 1,
    thickness: 1,
    color: AppTheme.cardBorder,
  );

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final nickname = author?.username ?? author?.label ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedCardHeader(
            avatarUrl: author?.avatarUrl,
            avatarName: author?.label,
            nickname: nickname,
            moduleLabel: item.headerModuleLabel,
            dateLabel: formatOmnifeedCardDate(item.itemDate),
          ),
          _sectionDivider,
          ColoredBox(
            color: Colors.white,
            child: InkWell(
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
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
                      const SizedBox(height: 6),
                    ],
                    Text(
                      item.displayBody,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onOpen,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.linkBlue,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Vedi dettaglio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _sectionDivider,
          _ActionBar(
            commentCount: item.commentCount,
            onComment: onComment ?? onOpen,
            onReact: onReact,
          ),
        ],
      ),
    );
  }
}

class _FeedCardHeader extends StatelessWidget {
  const _FeedCardHeader({
    required this.nickname,
    required this.dateLabel,
    this.avatarUrl,
    this.avatarName,
    this.moduleLabel,
  });

  final String nickname;
  final String dateLabel;
  final String? avatarUrl;
  final String? avatarName;
  final String? moduleLabel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(url: avatarUrl, name: avatarName),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AuthorLine(
                    nickname: nickname,
                    moduleLabel: moduleLabel,
                  ),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const _MenuButton(),
          ],
        ),
      ),
    );
  }
}

class _AuthorLine extends StatelessWidget {
  const _AuthorLine({required this.nickname, this.moduleLabel});

  final String nickname;
  final String? moduleLabel;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.1),
        children: [
          TextSpan(
            text: nickname,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.authorName,
            ),
          ),
          if (moduleLabel != null && moduleLabel!.isNotEmpty) ...[
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  Icons.play_arrow,
                  size: 14,
                  color: AppTheme.primary,
                ),
              ),
            ),
            TextSpan(
              text: moduleLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.name});

  final String? url;
  final String? name;

  static const _size = 30.0;

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: _size / 2,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    }
    return CircleAvatar(
      radius: _size / 2,
      backgroundColor: AppTheme.primary.withOpacity(0.12),
      child: Text(
        initial,
        style: const TextStyle(color: AppTheme.primary, fontSize: 12),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_horiz, size: 14, color: AppTheme.textPrimary),
          Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.textPrimary),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.commentCount,
    this.onComment,
    this.onReact,
  });

  final int commentCount;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Row(
          children: [
            Expanded(
              child: _FeedActionButton(
                onTap: onComment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mode_comment_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    if (commentCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FeedActionButton(
                onTap: onReact,
                child: const Icon(
                  Icons.thumb_up_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF0F4A35)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
