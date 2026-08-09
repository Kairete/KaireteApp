import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_profile.dart';

/// Cover blog in stile web (`kb-cover--split`), ottimizzata per mobile:
/// foto più alta, full-bleed, fade nella barra scura, Watch discreto.
class BlogCoverHeader extends StatelessWidget {
  const BlogCoverHeader({
    super.key,
    required this.profile,
    this.isWatched = false,
    this.watchLoading = false,
    this.canWatch = false,
    this.onWatchTap,
  });

  final BlogProfile profile;
  final bool isWatched;
  final bool watchLoading;
  final bool canWatch;
  final VoidCallback? onWatchTap;

  static const _bottomBg = Color(0xFF283848);
  static const _avatarBorder = Color(0xE60F1822);
  static const _topHeight = 168.0;
  static const _avatarSize = 84.0;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (MediaQuery.sizeOf(context).width * dpr).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                height: _topHeight,
                child: Stack(
                fit: StackFit.expand,
                children: [
                  if (profile.hasCover)
                    CachedNetworkImage(
                      imageUrl: profile.coverUrl!,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.2),
                      memCacheWidth: cacheW,
                      fadeInDuration: const Duration(milliseconds: 180),
                      errorWidget: (_, __, ___) => const _FallbackCover(),
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFF1A2838),
                      ),
                    )
                  else
                    const _FallbackCover(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x14000000),
                          Color(0xCC283848),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  if (canWatch)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _CoverWatchButton(
                        isWatched: isWatched,
                        isLoading: watchLoading,
                        onTap: onWatchTap,
                      ),
                    ),
                ],
              ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ColoredBox(
                    color: _bottomBg,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(112, 16, 16, 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 72),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (profile.ownerUsername?.isNotEmpty == true) ...[
                                const SizedBox(height: 5),
                                Text(
                                  profile.ownerUsername!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.72),
                                  ),
                                ),
                              ],
                              if (profile.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  profile.description.trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: Colors.white.withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: _CoverAvatar(url: profile.ownerAvatarUrl),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverWatchButton extends StatelessWidget {
  const _CoverWatchButton({
    required this.isWatched,
    required this.isLoading,
    this.onTap,
  });

  final bool isWatched;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = isWatched;
    return Material(
      color: active
          ? Colors.white.withOpacity(0.95)
          : Colors.black.withOpacity(0.42),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: active ? AppTheme.primary : Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active
                          ? Icons.notifications_active
                          : Icons.notifications_none_outlined,
                      size: 17,
                      color: active ? AppTheme.primary : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      active ? 'Unwatch' : 'Watch',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: active ? AppTheme.primary : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CoverAvatar extends StatelessWidget {
  const _CoverAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BlogCoverHeader._avatarSize,
      height: BlogCoverHeader._avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BlogCoverHeader._avatarBorder, width: 3),
        color: const Color(0xFF1A2838),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              memCacheWidth: 168,
              errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
            )
          : const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1A2838),
      child: Center(
        child: Icon(Icons.person, size: 34, color: Colors.white54),
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -0.5),
          end: Alignment(0.8, 0.8),
          colors: [
            Color(0xFF2F6AAD),
            Color(0xFF1A4480),
            Color(0xFF143560),
          ],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
    );
  }
}
