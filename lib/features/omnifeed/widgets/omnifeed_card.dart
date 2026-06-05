import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Card feed in stile web: header grigio, body bianco, footer grigio.
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
    final nickname = item.author?.username ?? item.author?.label ?? '';

    return Material(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    nickname: nickname,
                    date: formatOmnifeedHeaderDate(item.itemDate),
                    moduleLabel: item.headerModuleLabel,
                  ),
                  _Body(item: item),
                ],
              ),
            ),
            _Footer(
              commentCount: item.commentCount,
              reactionScore: item.reactionScore,
              onComment: onComment ?? onOpen,
              onReact: onReact,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nickname,
    required this.date,
    this.moduleLabel,
  });

  final String nickname;
  final String date;
  final String? moduleLabel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.headerBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nickname.isNotEmpty || (moduleLabel?.isNotEmpty ?? false))
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 2,
                children: [
                  if (nickname.isNotEmpty)
                    Text(
                      nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  if (moduleLabel != null && moduleLabel!.isNotEmpty) ...[
                    const Text(
                      '›',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      moduleLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item});

  final OmnifeedItem item;

  @override
  Widget build(BuildContext context) {
    final body = item.displayBody;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.showsModuleTitle) ...[
            Text(
              item.moduleTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            if (body.isNotEmpty) const SizedBox(height: 10),
          ],
          if (body.isNotEmpty)
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
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
    final hasReactions = reactionScore > 0;

    return ColoredBox(
      color: AppTheme.footerBg,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            TextButton.icon(
              onPressed: onComment,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(
                commentCount > 0 ? 'Commenti ($commentCount)' : 'Commenti',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Center(
                child: TextButton.icon(
                  onPressed: onReact,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        hasReactions ? AppTheme.primary : AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    hasReactions ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                  ),
                  label: Text(
                    hasReactions ? 'Mi piace ($reactionScore)' : 'Mi piace',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasReactions ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
