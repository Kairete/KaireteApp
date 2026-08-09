import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/api_url.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';

/// Card stile Facebook: avatar sopra, nickname, bottone azione sotto.
class SuggestionFacebookCard extends StatelessWidget {
  const SuggestionFacebookCard({
    super.key,
    required this.item,
    required this.onAction,
    this.onDismiss,
    this.busy = false,
  });

  final SuggestionItem item;
  final VoidCallback onAction;
  final VoidCallback? onDismiss;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final avatar = ApiUrl.resolve(item.avatarUrl);
    return Container(
      width: 148,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.feedItemChromeBg,
                backgroundImage:
                    avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? Text(
                        item.title.isNotEmpty
                            ? item.title.substring(0, 1).toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
              ),
              if (onDismiss != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: InkWell(
                    onTap: onDismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Color(0xFFE8EAED),
                      child: Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (item.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      item.actionLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
