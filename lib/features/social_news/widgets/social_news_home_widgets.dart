import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_detail_page.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/social_news/models/social_news_feed_mapper.dart';
import 'package:kairete/features/social_news/models/social_news_models.dart';

class SocialNewsCategoryBar extends StatelessWidget {
  const SocialNewsCategoryBar({super.key, required this.category});

  final SocialNewsCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: category.headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
        ],
      ),
    );
  }
}

class SocialNewsHomeBlockWidget extends StatelessWidget {
  const SocialNewsHomeBlockWidget({super.key, required this.block});

  final SocialNewsHomeBlock block;

  void _openArticle(BuildContext context, SocialNewsArticle article) {
    Get.to(() => OmnifeedDetailPage(item: article.toFeedItem()));
  }

  @override
  Widget build(BuildContext context) {
    final layout = block.layoutMobile;
    if (layout == 'category_sections') {
      return _CategorySectionsBlock(
        block: block,
        onTap: (article) => _openArticle(context, article),
      );
    }
    return _FeaturedListBlock(
      block: block,
      onTap: (article) => _openArticle(context, article),
    );
  }
}

class _FeaturedListBlock extends StatelessWidget {
  const _FeaturedListBlock({required this.block, required this.onTap});

  final SocialNewsHomeBlock block;
  final ValueChanged<SocialNewsArticle> onTap;

  @override
  Widget build(BuildContext context) {
    final featured = block.featured;
    final articles = block.articles;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SocialNewsCategoryBar(category: block.category),
          if (featured != null)
            InkWell(
              onTap: () => onTap(featured),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _FeaturedArticleCard(
                  article: featured,
                  color: block.category.headerColor,
                  compact: true,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                for (final article in articles)
                  _ArticleListTile(
                    article: article,
                    color: block.category.headerColor,
                    onTap: () => onTap(article),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySectionsBlock extends StatelessWidget {
  const _CategorySectionsBlock({required this.block, required this.onTap});

  final SocialNewsHomeBlock block;
  final ValueChanged<SocialNewsArticle> onTap;

  @override
  Widget build(BuildContext context) {
    final all = [
      if (block.featured != null) block.featured!,
      ...block.articles,
    ];
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SocialNewsCategoryBar(category: block.category),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                for (final article in all)
                  _ArticleListTile(
                    article: article,
                    color: block.category.headerColor,
                    onTap: () => onTap(article),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard({
    required this.article,
    required this.color,
    this.compact = false,
  });

  final SocialNewsArticle article;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final preview = article.lead.isNotEmpty ? article.lead : article.previewText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: compact ? 180 : 220,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: _ArticleCoverImage(article: article, fallbackColor: color),
        ),
        const SizedBox(height: 10),
        Text(
          article.title,
          style: TextStyle(
            fontSize: compact ? 18 : 22,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            preview,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  const _ArticleListTile({
    required this.article,
    required this.color,
    required this.onTap,
  });

  final SocialNewsArticle article;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = formatFeedRelativeDate(article.articleDate);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _ArticleCoverImage(
                article: article,
                fallbackColor: color,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCoverImage extends StatelessWidget {
  const _ArticleCoverImage({
    required this.article,
    required this.fallbackColor,
    this.fit = BoxFit.cover,
  });

  final SocialNewsArticle article;
  final Color fallbackColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = article.coverUrl.trim();
    if (url.isEmpty) {
      return ColoredBox(color: fallbackColor);
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      errorWidget: (_, __, ___) => ColoredBox(color: fallbackColor),
    );
  }
}
