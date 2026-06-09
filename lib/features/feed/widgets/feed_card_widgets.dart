import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_reaction_icon.dart';
import 'package:kairete/core/widgets/reaction_picker.dart';

const feedCardDivider = Divider(
  height: 1,
  thickness: 1,
  color: AppTheme.cardBorder,
);

class FeedCardShell extends StatelessWidget {
  const FeedCardShell({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    this.comments = const [],
  });

  final Widget header;
  final Widget body;
  final Widget footer;
  final List<Widget> comments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          feedCardDivider,
          ColoredBox(color: Colors.white, child: body),
          feedCardDivider,
          footer,
          for (final comment in comments) ...[
            feedCardDivider,
            ColoredBox(color: Colors.white, child: comment),
          ],
        ],
      ),
    );
  }
}

class FeedCardHeaderBar extends StatelessWidget {
  const FeedCardHeaderBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: child,
      ),
    );
  }
}

class FeedCardAvatar extends StatelessWidget {
  const FeedCardAvatar({this.url, this.name, this.onTap});

  final String? url;
  final String? name;
  final VoidCallback? onTap;

  static const _size = 32.0;

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    Widget avatar;
    if (url != null && url!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: _size / 2,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    } else {
      avatar = CircleAvatar(
        radius: _size / 2,
        backgroundColor: AppTheme.primary.withOpacity(0.12),
        child: Text(
          initial,
          style: const TextStyle(color: AppTheme.primary, fontSize: 13),
        ),
      );
    }
    if (onTap == null) return avatar;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: avatar,
    );
  }
}

/// Riga autore cliccabile (nickname + modulo opzionale). Usa Row invece di
/// RichText/WidgetSpan: i tap sui nickname erano spesso ignorati.
class FeedCardAuthorLine extends StatelessWidget {
  const FeedCardAuthorLine({
    super.key,
    required this.nickname,
    this.moduleLabel,
    this.onAuthorTap,
    this.onModuleTap,
  });

  final String nickname;
  final String? moduleLabel;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onModuleTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _AuthorTapLabel(
            label: nickname,
            onTap: onAuthorTap,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.authorName,
              fontSize: 14,
            ),
          ),
        ),
        if (moduleLabel != null && moduleLabel!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.play_arrow,
              size: 15,
              color: AppTheme.primary,
            ),
          ),
          Flexible(
            child: _AuthorTapLabel(
              label: moduleLabel!,
              onTap: onModuleTap,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FeedCardAuthorHeader extends StatelessWidget {
  const FeedCardAuthorHeader({
    super.key,
    this.avatarUrl,
    this.authorName,
    this.moduleLabel,
    this.dateLabel,
    this.onAuthorTap,
    this.onModuleTap,
    this.trailing = const FeedCardMenuButton(),
  });

  final String? avatarUrl;
  final String? authorName;
  final String? moduleLabel;
  final String? dateLabel;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onModuleTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return FeedCardHeaderBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedCardAvatar(
            url: avatarUrl,
            name: authorName,
            onTap: onAuthorTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedCardAuthorLine(
                  nickname: authorName ?? '',
                  moduleLabel: moduleLabel,
                  onAuthorTap: onAuthorTap,
                  onModuleTap: onModuleTap,
                ),
                if (dateLabel != null && dateLabel!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    dateLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _AuthorTapLabel extends StatelessWidget {
  const _AuthorTapLabel({
    required this.label,
    required this.style,
    this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (onTap == null) return text;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: text,
    );
  }
}

class FeedCardMenuButton extends StatelessWidget {
  const FeedCardMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_horiz, size: 15, color: AppTheme.textPrimary),
          Icon(Icons.arrow_drop_down, size: 15, color: AppTheme.textPrimary),
        ],
      ),
    );
  }
}

class FeedCardActionBar extends StatelessWidget {
  const FeedCardActionBar({
    super.key,
    required this.commentCount,
    this.likeCount = 0,
    this.visitorReactionId,
    this.onComment,
    this.onReact,
  });

  final int commentCount;
  final int likeCount;
  final int? visitorReactionId;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: _FeedActionButton(
                onTap: onComment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mode_comment_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    if (commentCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$commentCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FeedActionButton(
                onTap: onReact == null
                    ? null
                    : () => pickReactionAndApply(context, onReact!),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FeedReactionIcon(
                      visitorReactionId: visitorReactionId,
                      size: 16,
                    ),
                    if (likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedCardDetailLink extends StatelessWidget {
  const FeedCardDetailLink({super.key, this.onTap, this.visible = true});

  final VoidCallback? onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.linkBlue,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Mostra più dettagli',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF0F4A35)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Commento/risposta sotto il footer della card feed (stile web OmniFeed).
class FeedCommentTile extends StatelessWidget {
  const FeedCommentTile({
    super.key,
    required this.authorName,
    this.avatarUrl,
    this.dateLabel,
    required this.message,
    this.messageHtml,
    this.likeCount = 0,
    this.commentCount = 0,
    this.visitorReactionId,
    this.showCommentButton = true,
    this.onAuthorTap,
    this.onLike,
    this.onComment,
  });

  final String authorName;
  final String? avatarUrl;
  final String? dateLabel;
  final String message;
  final String? messageHtml;
  final int likeCount;
  final int commentCount;
  final int? visitorReactionId;
  final bool showCommentButton;
  final VoidCallback? onAuthorTap;
  final Future<void> Function(int reactionId)? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final useHtml =
        message.trim().isEmpty && messageHtml?.trim().isNotEmpty == true;
    final body = useHtml
        ? Html(
            data: messageHtml!,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                lineHeight: LineHeight(1.35),
                color: Colors.black,
              ),
              'p': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          )
        : Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: Colors.black,
            ),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedCardAvatar(
            url: avatarUrl,
            name: authorName,
            onTap: onAuthorTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuthorDateLine(
                  authorName: authorName,
                  dateLabel: dateLabel,
                  onAuthorTap: onAuthorTap,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: body),
                    const SizedBox(width: 8),
                    _FeedCommentActions(
                      likeCount: likeCount,
                      commentCount: commentCount,
                      visitorReactionId: visitorReactionId,
                      showCommentButton: showCommentButton,
                      onLike: onLike,
                      onComment: onComment,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorDateLine extends StatelessWidget {
  const _AuthorDateLine({
    required this.authorName,
    this.dateLabel,
    this.onAuthorTap,
  });

  final String authorName;
  final String? dateLabel;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AuthorTapLabel(
          label: authorName,
          onTap: onAuthorTap,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.authorName,
            fontSize: 14,
          ),
        ),
        if (dateLabel != null && dateLabel!.isNotEmpty) ...[
          const Text(
            ' · ',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            dateLabel!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _FeedCommentActions extends StatelessWidget {
  const _FeedCommentActions({
    required this.likeCount,
    required this.commentCount,
    required this.showCommentButton,
    this.visitorReactionId,
    this.onLike,
    this.onComment,
  });

  final int likeCount;
  final int commentCount;
  final bool showCommentButton;
  final int? visitorReactionId;
  final Future<void> Function(int reactionId)? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCommentButton) ...[
          _FeedCommentIconButton(
            icon: Icons.mode_comment_outlined,
            count: commentCount,
            onTap: onComment,
          ),
          const SizedBox(width: 4),
        ],
        _FeedCommentIconButton(
          icon: Icons.thumb_up_outlined,
          count: likeCount,
          visitorReactionId: visitorReactionId,
          onTap: onLike == null
              ? null
              : () => pickReactionAndApply(context, onLike!),
        ),
      ],
    );
  }
}

class _FeedCommentIconButton extends StatelessWidget {
  const _FeedCommentIconButton({
    required this.icon,
    required this.count,
    this.visitorReactionId,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final int? visitorReactionId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF0F4A35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon == Icons.thumb_up_outlined)
                FeedReactionIcon(
                  visitorReactionId: visitorReactionId,
                  size: 14,
                )
              else
                Icon(icon, size: 14, color: Colors.white),
              if (count > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
