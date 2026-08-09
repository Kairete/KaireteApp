import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/media/widgets/media_feed_card.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_card.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
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
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
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

              final tab = c.selectedTab.value;

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
                    SliverToBoxAdapter(
                      child: _ProfileTabs(
                        selected: tab,
                        onSelect: c.selectTab,
                      ),
                    ),
                    if (c.showCompose)
                      SliverToBoxAdapter(
                        child: _ComposePrompt(onTap: c.openCompose),
                      ),
                    ..._tabSlivers(c, tab),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            }),
          ),
          const FeedInlineReplyBar(),
        ],
      ),
    );
  }

  List<Widget> _tabSlivers(UserProfileController c, ProfileTab tab) {
    switch (tab) {
      case ProfileTab.feed:
        if (c.isFeedLoading.value && c.items.isEmpty) {
          return const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ];
        }
        if (c.items.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Nessuna attività nel profilo.')),
              ),
            ),
          ];
        }
        c.appWidgetsPayload.value;
        final slots = c.injectedSlots(c.items.toList());
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final slot = slots[index];
                if (slot is SuggestionsRailMarker ||
                    slot.runtimeType.toString() ==
                        'SuggestionsRailMarker') {
                  final marker = slot is SuggestionsRailMarker
                      ? slot
                      : const SuggestionsRailMarker();
                  return SuggestionsFeedRail(marker: marker);
                }
                if (slot is AppWidgetStripMarker) {
                  return AppWidgetStrip(widgets: slot.widgets);
                }
                final item = slot as OmnifeedItem;
                return OmnifeedFeedCard(
                  key: ValueKey(item.itemId),
                  item: item,
                  onOpen: () => c.openDetail(item),
                  onComment: () => c.openDetail(item),
                  onReact: (reactionId) =>
                      c.react(item, reactionId: reactionId),
                  onBookmark: () => c.toggleBookmark(item),
                  onShareInternal: () async {
                    final result = await showFeedShareInternal(
                      context: context,
                      itemId: item.itemId,
                      previewText:
                          item.messagePlainText ?? item.contentTitle,
                    );
                    if (result != null) {
                      c.applyShareResult(item.itemId, result);
                    }
                  },
                  onShareExternal: () async {
                    final result = await showFeedShareExternal(
                      context: context,
                      itemId: item.itemId,
                      viewUrl: item.viewUrl,
                    );
                    if (result != null) {
                      c.applyShareResult(item.itemId, result);
                    }
                  },
                  onAuthorTap: () => c.openAuthor(item),
                  onBlogTap: item.contentType == 'ubs_blog_entry'
                      ? () => c.openBlog(item)
                      : null,
                  onForumTap: item.contentType == 'thread'
                      ? () => c.openForum(item)
                      : null,
                  onMediaTap: item.contentType == 'xfmg_media'
                      ? () => OmnifeedNavigation.openMediaAlbum(item)
                      : null,
                  onMediaCategoryTap: item.contentType == 'xfmg_media'
                      ? () => OmnifeedNavigation.openMediaCategory(item)
                      : null,
                  onTagTap: TagFeedNavigation.openTag,
                  showOwnerActions: c.canShowOwnerActions(item),
                  onEdit: c.canEditItem(item) ? () => c.editItem(item) : null,
                  onDelete:
                      c.canDeleteItem(item) ? () => c.deleteItem(item) : null,
                  onHighlight: (item.canHighlight || item.isHighlighted)
                      ? () => c.toggleHighlight(item)
                      : null,
                  onCommentsChanged: c.loadFeed,
                );
              },
              childCount: slots.length,
            ),
          ),
        ];
      case ProfileTab.media:
        if (c.isMediaLoading.value && c.mediaItems.isEmpty) {
          return const [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          ];
        }
        if (c.mediaItems.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Nessun media.')),
              ),
            ),
          ];
        }
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = c.mediaItems[index];
                return MediaFeedCard(
                  key: ValueKey(item.mediaId),
                  item: item,
                  showAlbumInHeader: true,
                  onOpen: () => c.openMediaDetail(item),
                  onComment: () => c.openMediaDetail(item),
                  onShareInternal: () async {
                    final itemId = OmnifeedItemId.encode(
                      OmnifeedItemId.typeMedia,
                      item.mediaId,
                    );
                    final result = await showFeedShareInternal(
                      context: context,
                      itemId: itemId,
                      previewText: item.description ?? item.title,
                    );
                    if (result != null) {
                      c.applyShareResult(itemId, result);
                    }
                  },
                  onShareExternal: () async {
                    final itemId = OmnifeedItemId.encode(
                      OmnifeedItemId.typeMedia,
                      item.mediaId,
                    );
                    final result = await showFeedShareExternal(
                      context: context,
                      itemId: itemId,
                      viewUrl: item.viewUrl,
                    );
                    if (result != null) {
                      c.applyShareResult(itemId, result);
                    }
                  },
                  onAuthorTap: () => OmnifeedNavigation.openUserProfile(
                    item.author?.userId,
                  ),
                  onThumbnailTap: () => c.openMediaDetail(item),
                  onTagTap: TagFeedNavigation.openTag,
                );
              },
              childCount: c.mediaItems.length,
            ),
          ),
        ];
      case ProfileTab.about:
        return [
          SliverToBoxAdapter(
            child: _AboutTab(
              profile: c.profile.value!,
              onFollowing: c.openFollowing,
              onFollowers: c.openFollowers,
            ),
          ),
        ];
    }
  }
}
class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.selected, required this.onSelect});

  final ProfileTab selected;
  final ValueChanged<ProfileTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _TabButton(
                label: 'Feed',
                selected: selected == ProfileTab.feed,
                onTap: () => onSelect(ProfileTab.feed),
              ),
              _TabButton(
                label: 'Media',
                selected: selected == ProfileTab.media,
                onTap: () => onSelect(ProfileTab.media),
              ),
              _TabButton(
                label: 'About',
                selected: selected == ProfileTab.about,
                onTap: () => onSelect(ProfileTab.about),
              ),
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppTheme.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
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
              top: 10,
              right: 10,
              child: _CoverActions(controller: controller, profile: profile),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (profile.isStaff) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Staff',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_profileBlurb(profile).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _profileBlurb(profile),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
              if (profile.registerDate > 0 || profile.lastActivity > 0) ...[
                const SizedBox(height: 10),
                _ProfileMetaDates(profile: profile),
              ],
              const SizedBox(height: 10),
              _StatsRow(profile: profile),
              const SizedBox(height: 12),
              _FollowStatsRow(
                followingCount: profile.followingCount,
                followersCount: profile.followersCount,
                onFollowing: controller.openFollowing,
                onFollowers: controller.openFollowers,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverActions extends StatelessWidget {
  const _CoverActions({required this.controller, required this.profile});

  final UserProfileController controller;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isSelf = controller.isCurrentUser;
    final buttons = <Widget>[];

    if (!isSelf && (profile.canFollow || profile.isFollowed)) {
      buttons.add(
        Obx(() {
          final loading = controller.followLoading.value;
          final followed = controller.profile.value?.isFollowed ?? false;
          return _CoverLinkButton(
            label: followed ? 'Non seguire' : 'Segui',
            loading: loading,
            onTap: loading ? null : controller.toggleFollow,
          );
        }),
      );
    }

    if (!isSelf && profile.canReport) {
      buttons.add(
        Obx(() {
          final loading = controller.reportLoading.value;
          return _CoverLinkButton(
            label: 'Segnala',
            loading: loading,
            onTap: loading ? null : controller.reportUser,
          );
        }),
      );
    }

    if (isSelf && profile.canEditBanner) {
      buttons.add(
        Obx(() {
          final loading = controller.coverLoading.value;
          return _CoverLinkButton(
            label: 'Modifica cover',
            loading: loading,
            onTap: loading ? null : controller.editCover,
          );
        }),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    // Stile XF memberHeader-actionTop + buttonGroup / button--link
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: buttons,
        ),
      ),
    );
  }
}

/// Bottone stile XenForo `button button--link` sulla cover.
class _CoverLinkButton extends StatelessWidget {
  const _CoverLinkButton({
    required this.label,
    this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.white.withOpacity(0.85), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
        ),
      ),
    );
  }
}

class _FollowStatsRow extends StatelessWidget {
  const _FollowStatsRow({
    required this.followingCount,
    required this.followersCount,
    required this.onFollowing,
    required this.onFollowers,
  });

  final int followingCount;
  final int followersCount;
  final VoidCallback onFollowing;
  final VoidCallback onFollowers;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('it');
    return Row(
      children: [
        _FollowLink(
          value: fmt.format(followingCount),
          label: 'Following',
          onTap: onFollowing,
        ),
        const SizedBox(width: 18),
        _FollowLink(
          value: fmt.format(followersCount),
          label: 'Followers',
          onTap: onFollowers,
        ),
      ],
    );
  }
}

class _FollowLink extends StatelessWidget {
  const _FollowLink({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' $label',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.profile,
    required this.onFollowing,
    required this.onFollowers,
  });

  final UserProfile profile;
  final VoidCallback onFollowing;
  final VoidCallback onFollowers;

  @override
  Widget build(BuildContext context) {
    final about = profile.about.trim();
    final signature = profile.signaturePlain.trim().isNotEmpty
        ? profile.signaturePlain.trim()
        : profile.signature.trim();
    final personal = profile.personalFields;
    final contact = profile.contactFields;
    final hasDetails = _hasDetails(profile, personal);
    final hasContact = profile.canViewIdentities &&
        (profile.canStartConversation || contact.isNotEmpty);
    final hasFollowing = profile.followingPreview.isNotEmpty;
    final hasFollowers = profile.followersPreview.isNotEmpty;
    final hasTrophies = profile.trophies.isNotEmpty;
    final hasContent = about.isNotEmpty ||
        hasDetails ||
        hasContact ||
        signature.isNotEmpty ||
        hasFollowing ||
        hasFollowers ||
        hasTrophies;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: !hasContent
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${profile.username} non ha fornito altre informazioni.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (about.isNotEmpty)
                    _AboutSection(
                      child: Text(
                        about,
                        style: const TextStyle(fontSize: 14, height: 1.45),
                      ),
                    ),
                  if (hasDetails)
                    _AboutSection(
                      child: Column(
                        children: [
                          if (_formatDob(profile) != null)
                            _AboutPair(
                              label: 'Compleanno',
                              value: _birthdayValue(profile),
                            ),
                          if (profile.website.isNotEmpty)
                            _AboutPair(
                              label: 'Sito web',
                              value: profile.website,
                              isLink: true,
                            ),
                          if (profile.location.isNotEmpty)
                            _AboutPair(
                              label: 'Località',
                              value: profile.location,
                            ),
                          for (final field in personal)
                            _AboutPair(
                              label: field.title.isNotEmpty
                                  ? field.title
                                  : field.id,
                              value: field.value,
                            ),
                        ],
                      ),
                    ),
                  if (hasContact)
                    _AboutSection(
                      title: 'Contatti',
                      child: Column(
                        children: [
                          if (profile.canStartConversation)
                            _AboutPair(
                              label: 'Conversazione',
                              value: 'Avvia conversazione',
                              isLink: true,
                              onTap: () => AppToast.info(
                                'Conversazioni',
                                'Non ancora disponibili in app.',
                              ),
                            ),
                          for (final field in contact)
                            _AboutPair(
                              label: field.title.isNotEmpty
                                  ? field.title
                                  : field.id,
                              value: field.value,
                            ),
                        ],
                      ),
                    ),
                  if (signature.isNotEmpty)
                    _AboutSection(
                      title: 'Firma',
                      child: Text(
                        signature,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  if (hasFollowing)
                    _AboutSection(
                      title: 'Seguiti',
                      child: _AvatarHeap(
                        users: profile.followingPreview,
                        total: profile.followingCount,
                        onMore: onFollowing,
                      ),
                    ),
                  if (hasFollowers)
                    _AboutSection(
                      title: 'Follower',
                      child: _AvatarHeap(
                        users: profile.followersPreview,
                        total: profile.followersCount,
                        onMore: onFollowers,
                      ),
                    ),
                  if (hasTrophies)
                    _AboutSection(
                      title: 'Trofei',
                      child: Column(
                        children: [
                          for (var i = 0; i < profile.trophies.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _TrophyRow(trophy: profile.trophies[i]),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  bool _hasDetails(UserProfile profile, List<ProfileField> personal) {
    return _formatDob(profile) != null ||
        profile.website.isNotEmpty ||
        profile.location.isNotEmpty ||
        personal.isNotEmpty;
  }

  String _birthdayValue(UserProfile profile) {
    final dob = _formatDob(profile)!;
    if (profile.age != null && profile.age! > 0) {
      return '$dob (Età: ${profile.age})';
    }
    return dob;
  }

  String? _formatDob(UserProfile profile) {
    final d = profile.dobDay;
    final m = profile.dobMonth;
    if (d == null || m == null || d <= 0 || m <= 0) return null;
    final y = profile.dobYear;
    if (y != null && y > 0) {
      return DateFormat('d/M/yyyy').format(DateTime(y, m, d));
    }
    return DateFormat('d/M').format(DateTime(2000, m, d));
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.child, this.title});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}

class _AboutPair extends StatelessWidget {
  const _AboutPair({
    required this.label,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 13.5,
      height: 1.3,
      color: isLink ? AppTheme.linkBlue : Colors.black87,
      decoration: isLink ? TextDecoration.underline : TextDecoration.none,
      decorationColor: AppTheme.linkBlue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    child: Text(value, style: valueStyle),
                  )
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}

class _AvatarHeap extends StatelessWidget {
  const _AvatarHeap({
    required this.users,
    required this.total,
    required this.onMore,
  });

  final List<ProfileUserPreview> users;
  final int total;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final more = total > users.length ? total - users.length : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final user in users)
              InkWell(
                onTap: () => OmnifeedNavigation.openUserProfile(user.userId),
                child: _MiniAvatar(url: user.avatarUrl, name: user.username),
              ),
          ],
        ),
        if (more > 0) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: onMore,
            child: Text(
              '… e altri $more.',
              style: const TextStyle(
                color: AppTheme.linkBlue,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primary.withOpacity(0.12),
      child: Text(
        initial,
        style: const TextStyle(color: AppTheme.primary, fontSize: 12),
      ),
    );
  }
}

class _TrophyRow extends StatelessWidget {
  const _TrophyRow({required this.trophy});

  final ProfileTrophy trophy;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d/M/yyyy');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            '${trophy.trophyPoints}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trophy.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trophy.awardDate > 0)
                    Text(
                      dateFmt.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          trophy.awardDate * 1000,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              if (trophy.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  trophy.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
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

class _ProfileMetaDates extends StatelessWidget {
  const _ProfileMetaDates({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d/M/yyyy');
    final rows = <Widget>[];
    if (profile.registerDate > 0) {
      rows.add(
        _MetaDateLine(
          label: 'Iscritto',
          value: dateFmt.format(
            DateTime.fromMillisecondsSinceEpoch(profile.registerDate * 1000),
          ),
        ),
      );
    }
    if (profile.lastActivity > 0) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 4));
      rows.add(
        _MetaDateLine(
          label: 'Ultima attività',
          value: dateFmt.format(
            DateTime.fromMillisecondsSinceEpoch(profile.lastActivity * 1000),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _MetaDateLine extends StatelessWidget {
  const _MetaDateLine({required this.label, required this.value});

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
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('it');
    final chips = <Widget>[
      _StatChip(label: 'Messaggi', value: fmt.format(profile.messageCount)),
    ];
    if (profile.mediaCount > 0) {
      chips.add(
        _StatChip(label: 'Media', value: fmt.format(profile.mediaCount)),
      );
    }
    chips.addAll([
      _StatChip(label: 'Reazioni', value: fmt.format(profile.reactionScore)),
      _StatChip(label: 'Punti', value: fmt.format(profile.trophyPoints)),
    ]);
    if (profile.questionSolutionCount > 0) {
      chips.add(
        _StatChip(
          label: 'Soluzioni',
          value: fmt.format(profile.questionSolutionCount),
        ),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: chips,
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

String _profileBlurb(UserProfile profile) {
  final parts = <String>[];
  final title = profile.userTitle.trim();
  if (title.isNotEmpty) parts.add(title);
  if (profile.age != null && profile.age! > 0) {
    parts.add('${profile.age}');
  }
  final location = profile.location.trim();
  if (location.isNotEmpty) parts.add('da $location');
  return parts.join(' \u00b7 ');
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
