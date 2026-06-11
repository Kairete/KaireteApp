import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/media/models/media_album_profile.dart';

class AlbumCoverHeader extends StatelessWidget {
  const AlbumCoverHeader({super.key, required this.profile});

  final MediaAlbumProfile profile;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 168,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (profile.hasCover)
                  CachedNetworkImage(
                    imageUrl: profile.coverUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        _FallbackCover(title: profile.title),
                  )
                else
                  _FallbackCover(title: profile.title),
                if (profile.hasCover)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.ownerAvatarUrl != null &&
                    profile.ownerAvatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        CachedNetworkImageProvider(profile.ownerAvatarUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.photo_album_outlined, size: 22),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                      if (profile.ownerUsername?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          profile.ownerUsername!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (profile.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          profile.description.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D5A80), Color(0xFF293241)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
