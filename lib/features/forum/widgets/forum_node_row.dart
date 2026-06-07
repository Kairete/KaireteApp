import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Riga forum stile XenForo: icona a sinistra, titolo/stats/ultimo post a destra.
class ForumNodeRow extends StatelessWidget {
  const ForumNodeRow({
    super.key,
    required this.forum,
    this.onTap,
    this.onSubForumTap,
    this.showDivider = true,
  });

  final ForumNode forum;
  final VoidCallback? onTap;
  final ValueChanged<ForumNode>? onSubForumTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final stats = forum.typeData;
    final threads = stats?.discussionCount ?? 0;
    final messages = stats?.messageCount ?? 0;
    final lastTitle = stats?.lastThreadTitle?.trim();
    final lastUser = stats?.lastPostUsername?.trim();
    final lastDate = stats?.lastPostDate;
    final hasLastPost = lastTitle != null && lastTitle.isNotEmpty;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ForumRowIcon(title: forum.title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forum.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.linkBlue,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Threads: $threads · Messages: $messages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.2,
                        ),
                      ),
                      if (forum.description?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          forum.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (forum.subForums.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _SubForumsLine(
                          subForums: forum.subForums,
                          onSubForumTap: onSubForumTap,
                        ),
                      ],
                      if (hasLastPost) ...[
                        const SizedBox(height: 8),
                        Text(
                          lastTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.linkBlue,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(
                                text: formatOmnifeedCardDate(lastDate),
                              ),
                              if (lastUser != null && lastUser.isNotEmpty) ...[
                                const TextSpan(text: ' · '),
                                TextSpan(
                                  text: lastUser,
                                  style: const TextStyle(
                                    color: AppTheme.linkBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForumRowIcon extends StatelessWidget {
  const _ForumRowIcon({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _iconForTitle(title),
            size: 22,
            color: AppTheme.primary.withOpacity(0.75),
          ),
        ),
      ),
    );
  }

  IconData _iconForTitle(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('faq') || lower.contains('domand')) {
      return Icons.help_outline;
    }
    if (lower.contains('suggest') || lower.contains('propost')) {
      return Icons.lightbulb_outline;
    }
    if (lower.contains('announce') || lower.contains('annunc')) {
      return Icons.campaign_outlined;
    }
    if (lower.contains('sport')) {
      return Icons.sports_soccer_outlined;
    }
    return Icons.forum_outlined;
  }
}

class _SubForumsLine extends StatelessWidget {
  const _SubForumsLine({
    required this.subForums,
    this.onSubForumTap,
  });

  final List<ForumNode> subForums;
  final ValueChanged<ForumNode>? onSubForumTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 2,
      children: [
        const Text(
          'Sub-forums: ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        for (var i = 0; i < subForums.length; i++) ...[
          if (i > 0)
            const Text(
              ', ',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          GestureDetector(
            onTap: () => onSubForumTap?.call(subForums[i]),
            child: Text(
              subForums[i].title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.linkBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
