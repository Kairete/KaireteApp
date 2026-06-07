import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/groups/models/social_group.dart';

/// Pulsante Join/Unjoin sovrapposto in basso a destra sulla cover del gruppo.
class GroupCoverJoinButton extends StatelessWidget {
  const GroupCoverJoinButton({
    super.key,
    required this.group,
    required this.onTap,
    this.isLoading = false,
  });

  final SocialGroup group;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!group.canJoin && !group.canLeave) {
      return const SizedBox.shrink();
    }

    final isJoin = group.canJoin;
    return Material(
      color: isJoin ? AppTheme.primary : Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(4),
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isJoin ? Colors.white : AppTheme.primary,
                  ),
                )
              : Text(
                  isJoin ? 'Join' : 'Unjoin',
                  style: TextStyle(
                    color: isJoin ? Colors.white : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Cover gruppo con join in basso a destra.
class GroupCoverHeader extends StatelessWidget {
  const GroupCoverHeader({
    super.key,
    required this.group,
    this.height = 140,
    this.onJoinTap,
    this.isJoinLoading = false,
  });

  final SocialGroup group;
  final double height;
  final VoidCallback? onJoinTap;
  final bool isJoinLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (group.coverUrl?.isNotEmpty == true)
            CachedNetworkImage(
              imageUrl: group.coverUrl!,
              fit: BoxFit.cover,
            )
          else
            Container(color: AppTheme.primary.withOpacity(0.15)),
          if (group.coverUrl?.isNotEmpty == true)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GroupCoverJoinButton(
              group: group,
              onTap: onJoinTap,
              isLoading: isJoinLoading,
            ),
          ),
        ],
      ),
    );
  }
}
