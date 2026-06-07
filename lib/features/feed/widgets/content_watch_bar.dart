import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';

/// Pulsante Watch in alto a destra, sopra una lista (forum, blog, …).
class ContentWatchBar extends StatelessWidget {
  const ContentWatchBar({
    super.key,
    required this.isWatched,
    required this.onTap,
    this.isLoading = false,
    this.visible = true,
  });

  final bool isWatched;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          isWatched
                              ? Icons.notifications_active
                              : Icons.notifications_none_outlined,
                          size: 18,
                          color: isWatched
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isWatched ? 'Unwatch' : 'Watch',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isWatched
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
