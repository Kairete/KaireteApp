import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
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
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    final nickname = author?.username ?? author?.label ?? '';

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: author?.avatarUrl, name: author?.label),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AuthorLine(
                        nickname: nickname,
                        moduleLabel: item.headerModuleLabel,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatOmnifeedCardDate(item.itemDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _MenuButton(),
              ],
            ),
          ),
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.showsModuleTitle) ...[
                    Text(
                      item.moduleTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    item.displayBody,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      height: 1.35,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ActionBar(
            commentCount: item.commentCount,
            reactionScore: item.reactionScore,
            onComment: onComment ?? onOpen,
            onReact: onReact,
          ),
          const SizedBox(height: 12),
        ],
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
      text: TextSpan(
        style: const TextStyle(fontSize: 16, height: 1.25),
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
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.play_arrow,
                  size: 18,
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

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primary.withOpacity(0.12),
      child: Text(initial, style: const TextStyle(color: AppTheme.primary)),
    );
  }
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
        color: AppTheme.feedFooterBg,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_horiz, size: 18, color: AppTheme.textPrimary),
          Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.textPrimary),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.commentCount,
    required this.reactionScore,
    this.onComment,
    this.onReact,
  });

  final int commentCount;
  final int reactionScore;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.feedFooterBg,
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FeedActionButton(
              icon: Icons.reply,
              label: '$commentCount Risposte',
              onTap: onComment,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FeedActionButton(
              icon: Icons.thumb_up_outlined,
              label: reactionScore > 0 ? '$reactionScore Mi piace' : 'Mi piace',
              onTap: onReact,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF0F4A35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
