import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_refresh_button.dart';

enum OmnifeedComposeBarMode { newsfeed, blog }

/// Barra composizione in home: layout diverso per tab newsfeed e blog.
class OmnifeedComposeBar extends StatelessWidget {
  const OmnifeedComposeBar({
    super.key,
    required this.mode,
    this.onTapCompose,
    this.onTapRefresh,
    this.onTapBlog,
    this.onTapCreateBlog,
    this.isRefreshing = false,
  });

  final OmnifeedComposeBarMode mode;
  final VoidCallback? onTapCompose;
  final VoidCallback? onTapRefresh;
  final VoidCallback? onTapBlog;
  final VoidCallback? onTapCreateBlog;
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
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: mode == OmnifeedComposeBarMode.newsfeed
            ? _NewsfeedLayout(
                onTapCompose: onTapCompose,
                onTapRefresh: onTapRefresh,
                onTapBlog: onTapBlog,
                isRefreshing: isRefreshing,
              )
            : _BlogLayout(
                onTapRefresh: onTapRefresh,
                onTapBlog: onTapBlog,
                onTapCreateBlog: onTapCreateBlog,
                isRefreshing: isRefreshing,
              ),
      ),
    );
  }
}

class _NewsfeedLayout extends StatelessWidget {
  const _NewsfeedLayout({
    this.onTapCompose,
    this.onTapRefresh,
    this.onTapBlog,
    this.isRefreshing = false,
  });

  final VoidCallback? onTapCompose;
  final VoidCallback? onTapRefresh;
  final VoidCallback? onTapBlog;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTapCompose,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Scrivi qualcosa…',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            FeedRefreshButton(
              onTap: onTapRefresh,
              isLoading: isRefreshing,
              compact: true,
            ),
            const Spacer(),
            if (onTapBlog != null) _BlogButton(onTap: onTapBlog!),
          ],
        ),
      ],
    );
  }
}

class _BlogLayout extends StatelessWidget {
  const _BlogLayout({
    this.onTapRefresh,
    this.onTapBlog,
    this.onTapCreateBlog,
    this.isRefreshing = false,
  });

  final VoidCallback? onTapRefresh;
  final VoidCallback? onTapBlog;
  final VoidCallback? onTapCreateBlog;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onTapRefresh != null)
          FeedRefreshButton(
            onTap: onTapRefresh,
            isLoading: isRefreshing,
            compact: true,
          ),
        if (onTapRefresh != null) const SizedBox(width: 8),
        if (onTapBlog != null)
          Expanded(child: _BlogButton(onTap: onTapBlog!, expanded: true)),
        if (onTapBlog != null && onTapCreateBlog != null)
          const SizedBox(width: 8),
        if (onTapCreateBlog != null)
          Expanded(
            child: _ActionButton(
              onTap: onTapCreateBlog!,
              icon: Icons.add_circle_outline,
              label: 'Crea blog',
              background: const Color(0xFFE8F5EE),
              border: const Color(0xFF1B8F5A),
              foreground: AppTheme.brandPrimary,
            ),
          ),
      ],
    );
  }
}

class _BlogButton extends StatelessWidget {
  const _BlogButton({required this.onTap, this.expanded = false});

  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      onTap: onTap,
      icon: Icons.rss_feed,
      label: 'Blog',
      background: const Color(0xFFFFF6DF),
      border: const Color(0xFFE6A800),
      foreground: const Color(0xFF7A4E00),
      expanded: expanded,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
    this.expanded = false,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color background;
  final Color border;
  final Color foreground;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
