import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_refresh_button.dart';

/// Barra azioni media: aggiungi media e crea album.
class MediaActionBar extends StatelessWidget {
  const MediaActionBar({
    super.key,
    this.onTapRefresh,
    this.onTapAddMedia,
    this.onTapCreateAlbum,
    this.isRefreshing = false,
  });

  final VoidCallback? onTapRefresh;
  final VoidCallback? onTapAddMedia;
  final VoidCallback? onTapCreateAlbum;
  final bool isRefreshing;

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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: _ActionChip(
                icon: Icons.add_photo_alternate_outlined,
                label: 'Aggiungi media',
                onTap: onTapAddMedia,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChip(
                icon: Icons.create_new_folder_outlined,
                label: 'Crea album',
                onTap: onTapCreateAlbum,
              ),
            ),
            const SizedBox(width: 8),
            FeedRefreshButton(
              onTap: onTapRefresh,
              isRefreshing: isRefreshing,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
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
