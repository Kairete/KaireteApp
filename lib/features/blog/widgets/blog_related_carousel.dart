import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/api_url.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';

/// Carousel correlati: stesso chrome di Pubblicità / Follow, sotto l'HTML.
class BlogRelatedCarousel extends StatefulWidget {
  const BlogRelatedCarousel({
    super.key,
    required this.entryId,
    this.title = 'Potrebbe interessarti anche',
  });

  final int entryId;
  final String title;

  @override
  State<BlogRelatedCarousel> createState() => _BlogRelatedCarouselState();
}

class _BlogRelatedCarouselState extends State<BlogRelatedCarousel> {
  final _service = BlogService();
  List<BlogEntry> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BlogRelatedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryId != widget.entryId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _items = const [];
    });
    try {
      final items = await _service.fetchRelatedEntries(widget.entryId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
      });
    }
  }

  void _openRelated(BlogEntry entry) {
    final id = entry.blogEntryId;
    if (id <= 0) {
      AppToast.error('Articolo non disponibile.');
      return;
    }
    if (id == widget.entryId) return;
    Get.off(
      () => BlogDetailPage(entryId: id),
      preventDuplicates: false,
      routeName: '/blog-detail/$id',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _items.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = widget.title.trim().isNotEmpty
        ? widget.title.trim()
        : 'Potrebbe interessarti anche';

    late final Widget carouselBody;
    if (_loading && _items.isEmpty) {
      carouselBody = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else {
      carouselBody = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _RelatedCard(
                entry: _items[i],
                onTap: () => _openRelated(_items[i]),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        feedCardDivider,
        FeedCardHeaderBar(
          child: Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 18,
                color: AppTheme.brandPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        feedCardDivider,
        ColoredBox(
          color: Colors.white,
          child: carouselBody,
        ),
      ],
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({
    required this.entry,
    required this.onTap,
  });

  final BlogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = ApiUrl.resolve(entry.thumbnailUrl);
    final title = entry.title?.trim().isNotEmpty == true
        ? entry.title!.trim()
        : 'Articolo';
    final category = entry.category?.title.trim() ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: thumb.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: AppTheme.textPrimary,
              ),
            ),
            if (category.isNotEmpty)
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 28,
          color: AppTheme.brandPrimary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
