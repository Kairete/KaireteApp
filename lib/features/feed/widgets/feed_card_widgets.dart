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
    this.afterBody,
    this.beforeFooter,
    this.beforeFooterDivided = true,
    this.comments = const [],
  });

  final Widget header;
  final Widget body;
  /// Slot sotto il body (es. correlati), prima di tag/azioni.
  final Widget? afterBody;
  final Widget footer;
  final Widget? beforeFooter;
  /// Se false, niente linea tra [afterBody] e [beforeFooter] (es. tag sotto correlati).
  final bool beforeFooterDivided;
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
          if (afterBody != null) ColoredBox(color: Colors.white, child: afterBody!),
          if (beforeFooter != null) ...[
            if (beforeFooterDivided) feedCardDivider,
            ColoredBox(color: Colors.white, child: beforeFooter!),
          ],
          feedCardDivider,
          footer,
          if (comments.isNotEmpty)
            ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: comments,
              ),
            ),
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: child,
      ),
    );
  }
}

class FeedCardAvatar extends StatelessWidget {
  const FeedCardAvatar({
    this.url,
    this.name,
    this.onTap,
    this.size = 32,
  });

  final String? url;
  final String? name;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    final fontSize = size <= 26 ? 11.0 : 13.0;
    Widget avatar;
    if (url != null && url!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: AppTheme.brandPrimary.withOpacity(0.12),
        child: Text(
          initial,
          style: TextStyle(color: AppTheme.brandPrimary, fontSize: fontSize),
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
    this.activityLabel,
    this.followLabel,
    this.onAuthorTap,
    this.onModuleTap,
    this.onFollowTap,
  });

  final String nickname;
  final String? moduleLabel;
  /// Testo muto dopo il nickname (es. " ha condiviso un post").
  final String? activityLabel;
  /// Es. "Segui" accanto al nickname quando non c'è modulo (> blog/forum).
  final String? followLabel;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onModuleTap;
  final VoidCallback? onFollowTap;

  @override
  Widget build(BuildContext context) {
    final hasModule = moduleLabel != null && moduleLabel!.trim().isNotEmpty;
    final hasActivity =
        activityLabel != null && activityLabel!.trim().isNotEmpty;
    final hasFollow = !hasModule &&
        !hasActivity &&
        followLabel != null &&
        followLabel!.trim().isNotEmpty;

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
        if (hasActivity)
          Text(
            activityLabel!,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        if (hasModule) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '>',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.brandPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: _AuthorTapLabel(
              label: moduleLabel!,
              onTap: onModuleTap,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.brandPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
        if (hasFollow) ...[
          const SizedBox(width: 8),
          _AuthorTapLabel(
            label: followLabel!.trim(),
            onTap: onFollowTap,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.linkBlue,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _DateCategoryLine extends StatelessWidget {
  const _DateCategoryLine({
    required this.dateLabel,
    this.categoryLabel,
    this.onCategoryTap,
  });

  final String dateLabel;
  final String? categoryLabel;
  final VoidCallback? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final category = categoryLabel?.trim();
    if (category == null || category.isEmpty) {
      return Text(
        dateLabel,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          height: 1.0,
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      children: [
        Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            height: 1.0,
          ),
        ),
        const Text(
          ' - ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            height: 1.0,
          ),
        ),
        InkWell(
          onTap: onCategoryTap,
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.brandAccent,
              height: 1.0,
            ),
          ),
        ),
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
    this.activityLabel,
    this.followLabel,
    this.dateLabel,
    this.categoryLabel,
    this.onAuthorTap,
    this.onModuleTap,
    this.onFollowTap,
    this.onCategoryTap,
    this.trailing = const FeedCardMenuButton(),
  });

  final String? avatarUrl;
  final String? authorName;
  final String? moduleLabel;
  final String? activityLabel;
  final String? followLabel;
  final String? dateLabel;
  final String? categoryLabel;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onModuleTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onCategoryTap;
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
                  activityLabel: activityLabel,
                  followLabel: followLabel,
                  onAuthorTap: onAuthorTap,
                  onModuleTap: onModuleTap,
                  onFollowTap: onFollowTap,
                ),
                if (dateLabel != null && dateLabel!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _DateCategoryLine(
                    dateLabel: dateLabel!,
                    categoryLabel: categoryLabel,
                    onCategoryTap: onCategoryTap,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: trailing,
          ),
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
    this.isBookmarked = false,
    this.onBookmark,
    this.shareCount = 0,
    this.onShareInternal,
    this.onShareExternal,
  });

  final int commentCount;
  final int likeCount;
  final int? visitorReactionId;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final bool isBookmarked;
  final Future<void> Function()? onBookmark;
  final int shareCount;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;

  /// Solo le icone sono verdi (brand); i contatori restano scuri. Nessun bottone/chrome.
  static Color get _iconColor => AppTheme.brandPrimary;
  static const Color _countColor = Color(0xFF202124);
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: _FeedActionButton(
                onTap: onComment,
                child: _FeedFooterStat(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: _iconColor,
                  iconSize: _iconSize,
                  count: commentCount,
                  countColor: _countColor,
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (btnContext) => _FeedActionButton(
                  onTap: onReact == null
                      ? null
                      : () => pickReactionAndApply(btnContext, onReact!),
                  child: _FeedFooterStat(
                    iconWidget: FeedReactionIcon(
                      visitorReactionId: visitorReactionId,
                      size: _iconSize,
                      fallbackColor: _iconColor,
                      outlined: true,
                    ),
                    count: likeCount,
                    countColor: _countColor,
                  ),
                ),
              ),
            ),
            if (onBookmark != null)
              Expanded(
                child: _FeedActionButton(
                  // ignore: discarded_futures
                  onTap: () => onBookmark!(),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark_added_outlined
                        : Icons.bookmark_border_rounded,
                    color: _iconColor,
                    size: _iconSize,
                    weight: 300,
                    grade: -25,
                    opticalSize: 20,
                  ),
                ),
              ),
            if (onShareInternal != null)
              Expanded(
                child: _FeedActionButton(
                  onTap: onShareInternal,
                  child: _FeedFooterStat(
                    icon: Icons.repeat_rounded,
                    iconColor: _iconColor,
                    iconSize: _iconSize,
                    count: shareCount,
                    countColor: _countColor,
                  ),
                ),
              ),
            if (onShareExternal != null)
              Expanded(
                child: _FeedActionButton(
                  onTap: onShareExternal,
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: _iconColor,
                    size: _iconSize,
                    weight: 300,
                    grade: -25,
                    opticalSize: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Icona (+ contatore) a tratto sottile: il numero ha più peso ottico dell'icona.
class _FeedFooterStat extends StatelessWidget {
  const _FeedFooterStat({
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconSize = 20,
    required this.count,
    required this.countColor,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final double iconSize;
  final int count;
  final Color countColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget ??
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
              weight: 300,
              grade: -25,
              opticalSize: 20,
            ),
        if (count > 0) ...[
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: countColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
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
          'Continua',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Tag e link «Continua» nello stesso [Wrap]: Continua finisce sull'ultima riga
/// accanto agli ultimi tag; le righe sopra usano tutta la larghezza.
class FeedCardTagsContinueRow extends StatelessWidget {
  const FeedCardTagsContinueRow({
    super.key,
    this.tags = const [],
    this.onTagTap,
    this.onContinue,
    this.showContinue = false,
    this.continueLabel = 'Continua',
    this.embeddedInBody = false,
  });

  final List<String> tags;
  final void Function(String tag)? onTagTap;
  final VoidCallback? onContinue;
  final bool showContinue;
  final String continueLabel;
  final bool embeddedInBody;

  @override
  Widget build(BuildContext context) {
    final hasTags = tags.isNotEmpty;
    if (!hasTags && !showContinue) return const SizedBox.shrink();

    return Padding(
      padding: embeddedInBody
          ? const EdgeInsets.only(top: 8)
          : const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...tags.map(
            (tag) => GestureDetector(
              onTap: onTagTap == null ? null : () => onTagTap!(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  tag.startsWith('#') ? tag : '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (showContinue)
            TextButton(
              onPressed: onContinue,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.linkBlue,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                continueLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
        ],
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
    // Solo icona tappabile: niente Material/InkWell (niente “bottone” intorno).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Center(child: child),
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
    this.compactPadding = false,
    this.compactDense = false,
    this.avatarSize = 32,
    this.transparentBackground = false,
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
  final bool compactPadding;
  final bool compactDense;
  final double avatarSize;
  final bool transparentBackground;
  final VoidCallback? onAuthorTap;
  final Future<void> Function(int reactionId)? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final bodyFontSize = compactDense ? 13.0 : 14.0;
    final bodyLineHeight = compactDense ? 1.3 : 1.35;
    final useHtml =
        message.trim().isEmpty && messageHtml?.trim().isNotEmpty == true;
    final body = useHtml
        ? Html(
            data: messageHtml!,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(bodyFontSize),
                lineHeight: LineHeight(bodyLineHeight),
                color: Colors.black,
              ),
              'p': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          )
        : Text(
            message,
            style: TextStyle(
              fontSize: bodyFontSize,
              height: bodyLineHeight,
              color: Colors.black,
            ),
          );

    final avatarGap = compactDense ? 6.0 : 8.0;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedCardAvatar(
          url: avatarUrl,
          name: authorName,
          onTap: onAuthorTap,
          size: avatarSize,
        ),
        SizedBox(width: avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuthorDateLine(
                authorName: authorName,
                dateLabel: dateLabel,
                onAuthorTap: onAuthorTap,
                fontSize: compactDense ? 13 : 14,
              ),
              SizedBox(height: compactDense ? 1 : 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: body),
                  SizedBox(width: compactDense ? 4 : 6),
                  _FeedCommentActions(
                    likeCount: likeCount,
                    commentCount: commentCount,
                    visitorReactionId: visitorReactionId,
                    showCommentButton: showCommentButton,
                    compact: compactPadding,
                    onLike: onLike,
                    onComment: onComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (compactPadding) return content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: transparentBackground
          ? content
          : ColoredBox(color: Colors.white, child: content),
    );
  }
}

class _AuthorDateLine extends StatelessWidget {
  const _AuthorDateLine({
    required this.authorName,
    this.dateLabel,
    this.onAuthorTap,
    this.fontSize = 14,
  });

  final String authorName;
  final String? dateLabel;
  final VoidCallback? onAuthorTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AuthorTapLabel(
          label: authorName,
          onTap: onAuthorTap,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.authorName,
            fontSize: fontSize,
          ),
        ),
        if (dateLabel != null && dateLabel!.isNotEmpty) ...[
          Text(
            ' · ',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              fontSize: fontSize,
            ),
          ),
          Text(
            dateLabel!,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: fontSize - 1,
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
    this.compact = false,
    this.onLike,
    this.onComment,
  });

  final int likeCount;
  final int commentCount;
  final bool showCommentButton;
  final int? visitorReactionId;
  final bool compact;
  final Future<void> Function(int reactionId)? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? 2.0 : 4.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Come sul web: Like, poi quadratino conteggio, poi Rispondi.
        _FeedCommentLikeButton(
          visitorReactionId: visitorReactionId,
          compact: compact,
          onTap: onLike == null
              ? null
              : (btnContext) {
                  // ignore: discarded_futures
                  pickReactionAndApply(btnContext, onLike!);
                },
        ),
        if (likeCount > 0) ...[
          SizedBox(width: gap),
          _FeedCommentReactionCountSquare(
            count: likeCount,
            compact: compact,
            onTap: () => _showCommentReactionsSheet(context, likeCount),
          ),
        ],
        if (showCommentButton && onComment != null) ...[
          SizedBox(width: gap),
          GestureDetector(
            onTap: onComment,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 6,
                vertical: compact ? 2 : 3,
              ),
              child: Text(
                'Rispondi',
                style: TextStyle(
                  color: AppTheme.brandPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Like commento: solo icona (niente conteggio dentro).
class _FeedCommentLikeButton extends StatelessWidget {
  const _FeedCommentLikeButton({
    this.visitorReactionId,
    this.compact = false,
    this.onTap,
  });

  final int? visitorReactionId;
  final bool compact;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 10.0 : 11.0;
    final box = compact ? 18.0 : 20.0;
    final radius = compact ? 3.0 : 4.0;
    return Material(
      color: onTap == null
          ? AppTheme.brandPrimary.withValues(alpha: 0.45)
          : AppTheme.brandPrimary,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(context),
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: box,
          height: box,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppTheme.brandAppBarBorder),
            ),
            child: Center(
              child: FeedReactionIcon(
                visitorReactionId: visitorReactionId,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quadratino col solo numero: apre la lista reazioni (sheet).
class _FeedCommentReactionCountSquare extends StatelessWidget {
  const _FeedCommentReactionCountSquare({
    required this.count,
    this.compact = false,
    this.onTap,
  });

  final int count;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 16.0 : 18.0;
    final fontSize = compact ? 9.0 : 10.0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFFC8C8C8)),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showCommentReactionsSheet(BuildContext context, int count) {
  final label = count == 1 ? '1 reazione' : '$count reazioni';
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Chi ha reagito',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class FeedCardTagsRow extends StatelessWidget {
  const FeedCardTagsRow({
    super.key,
    required this.tags,
    this.onTagTap,
    /// Se true, niente padding orizzontale (il body della card lo fornisce già).
    this.embeddedInBody = false,
    /// Meno padding sopra (es. subito sotto i correlati).
    this.tightTop = false,
    /// Meno padding sotto (es. prima dei correlati).
    this.tightBottom = false,
  });

  final List<String> tags;
  final void Function(String tag)? onTagTap;
  final bool embeddedInBody;
  final bool tightTop;
  final bool tightBottom;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final compact = tightTop || tightBottom;
    return Padding(
      padding: embeddedInBody
          ? const EdgeInsets.only(top: 8)
          : tightTop
              ? const EdgeInsets.fromLTRB(12, 0, 12, 2)
              : tightBottom
                  ? const EdgeInsets.fromLTRB(12, 0, 12, 2)
                  : const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: compact ? 4 : 6,
        children: tags
            .map(
              (tag) => GestureDetector(
                onTap: onTagTap == null ? null : () => onTagTap!(tag),
                child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: compact ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  tag.startsWith('#') ? tag : '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class FeedCardFullWidthImages extends StatelessWidget {
  const FeedCardFullWidthImages({
    super.key,
    required this.imageUrls,
    this.onTap,
  });

  final List<String> imageUrls;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final url in imageUrls)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: onTap,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class FeedCardOwnerMenu extends StatelessWidget {
  const FeedCardOwnerMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onHighlight,
    this.isHighlighted = false,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHighlight;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null && onHighlight == null) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      splashRadius: 18,
      offset: const Offset(0, 24),
      child: const FeedCardMenuButton(),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
        if (value == 'highlight') onHighlight?.call();
      },
      itemBuilder: (_) => [
        if (onHighlight != null)
          PopupMenuItem(
            value: 'highlight',
            child: Text(isHighlighted ? 'Togli da alto' : 'Fissa in alto'),
          ),
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Modifica')),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Elimina')),
      ],
    );
  }
}
