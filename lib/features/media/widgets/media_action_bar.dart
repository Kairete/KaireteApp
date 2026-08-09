import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_refresh_button.dart';

/// Barra azioni media: aggiungi media, crea album, join/watch opzionale.
class MediaActionBar extends StatelessWidget {
  const MediaActionBar({
    super.key,
    this.onTapRefresh,
    this.onTapAddMedia,
    this.onTapCreateAlbum,
    this.onTapJoin,
    this.isRefreshing = false,
    this.showJoin = false,
    this.showCreateAlbum = true,
    this.isJoined = false,
    this.joinLoading = false,
  });

  final VoidCallback? onTapRefresh;
  final VoidCallback? onTapAddMedia;
  final VoidCallback? onTapCreateAlbum;
  final VoidCallback? onTapJoin;
  final bool isRefreshing;
  final bool showJoin;
  final bool showCreateAlbum;
  final bool isJoined;
  final bool joinLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.composeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          children: [
            Expanded(
              child: _ActionChip(
                icon: Icons.add_photo_alternate_outlined,
                label: 'Aggiungi media',
                onTap: onTapAddMedia,
              ),
            ),
            if (showCreateAlbum) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  icon: Icons.create_new_folder_outlined,
                  label: 'Crea album',
                  onTap: onTapCreateAlbum,
                ),
              ),
            ],
            if (showJoin) ...[
              const SizedBox(width: 8),
              _JoinChip(
                isJoined: isJoined,
                isLoading: joinLoading,
                onTap: onTapJoin,
              ),
            ],
            const SizedBox(width: 8),
            FeedRefreshButton(
              onTap: onTapRefresh,
              isLoading: isRefreshing,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppTheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
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

class _JoinChip extends StatelessWidget {
  const _JoinChip({
    required this.isJoined,
    required this.isLoading,
    this.onTap,
  });

  final bool isJoined;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isJoined ? AppTheme.primary : AppTheme.cardBorder,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isJoined
                          ? Icons.notifications_active
                          : Icons.notifications_none_outlined,
                      size: 15,
                      color:
                          isJoined ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isJoined ? 'Joined' : 'Join',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isJoined
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
