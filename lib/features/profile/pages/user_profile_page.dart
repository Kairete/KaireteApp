import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_card.dart';
import 'package:kairete/features/profile/controllers/user_profile_controller.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';
import 'package:kairete/features/profile/models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});

  final int userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final String _tag;
  late final UserProfileController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'profile_${widget.userId}';
    Get.delete<UserProfileController>(tag: _tag, force: true);
    _controller = Get.put(
      UserProfileController(userId: widget.userId),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<UserProfileController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      body: Obx(() {
        if (c.isLoading.value && c.profile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.errorMessage.value.isNotEmpty && c.profile.value == null) {
          return _ErrorState(
            message: c.errorMessage.value,
            onRetry: c.loadAll,
          );
        }
        final profile = c.profile.value;
        if (profile == null) {
          return const Center(child: Text('Profilo non disponibile.'));
        }

        return RefreshIndicator(
          onRefresh: c.loadAll,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                title: Text(profile.username),
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(controller: c, profile: profile),
              ),
              if (c.isCurrentUser)
                SliverToBoxAdapter(child: _ComposePrompt(onTap: c.openCompose)),
              if (c.isFeedLoading.value && c.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (c.items.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Nessuna attività nel profilo.')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = c.items[index];
                      return OmnifeedCard(
                        item: item,
                        onOpen: () => c.openDetail(item),
                        onComment: () => c.openDetail(item),
                        onReact: (reactionId) =>
                            c.react(item, reactionId: reactionId),
                        onAuthorTap: () => c.openAuthor(item),
                        onBlogTap: item.contentType == 'ubs_blog_entry'
                            ? () => c.openBlog(item)
                            : null,
                        onForumTap: item.contentType == 'thread'
                            ? () => c.openForum(item)
                            : null,
                        onTagTap: TagFeedNavigation.openTag,
                        showOwnerActions: c.isCurrentUser,
                        onEdit: () => c.editItem(item),
                        onDelete: () => c.deleteItem(item),
                      );
                    },
                    childCount: c.items.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller, required this.profile});

  final UserProfileController controller;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: profile.bannerUrl != null
                  ? CachedNetworkImage(
                      imageUrl: profile.bannerUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _BannerFallback(),
                    )
                  : const _BannerFallback(),
            ),
            Positioned(
              left: 16,
              bottom: -44,
              child: _ProfileAvatar(
                url: profile.avatarUrl,
                name: profile.username,
              ),
            ),
          ],
        ),
        const SizedBox(height: 52),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              if (profile.userTitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  profile.userTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              if (profile.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  profile.location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _StatsRow(profile: profile),
              if (profile.about.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  profile.about.trim(),
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              ],
              if (!controller.isCurrentUser && profile.canFollow) ...[
                const SizedBox(height: 16),
                Obx(() {
                  final loading = controller.followLoading.value;
                  final followed = controller.profile.value?.isFollowed ?? false;
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: loading ? null : controller.toggleFollow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(followed ? 'Unfollow' : 'Follow'),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 40,
          backgroundImage: CachedNetworkImageProvider(url!),
        ),
      );
    }
    return CircleAvatar(
      radius: 44,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: AppTheme.primary.withOpacity(0.12),
        child: Text(
          initial,
          style: const TextStyle(color: AppTheme.primary, fontSize: 28),
        ),
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFEDF6FD));
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _StatChip(label: 'Messaggi', value: '${profile.messageCount}'),
        _StatChip(label: 'Reazioni', value: '${profile.reactionScore}'),
        _StatChip(label: 'Trophy', value: '${profile.trophyPoints}'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _ComposePrompt extends StatelessWidget {
  const _ComposePrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Text(
            'Scrivi qualcosa…',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
