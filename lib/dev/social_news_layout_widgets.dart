import 'package:flutter/material.dart';
import 'package:kairete/dev/social_news_preview_data.dart';

class SocialNewsLayoutPreview extends StatelessWidget {
  const SocialNewsLayoutPreview({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        child,
        const SizedBox(height: 8),
      ],
    );
  }
}

class SocialNewsCategoryBar extends StatelessWidget {
  const SocialNewsCategoryBar({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: category.color,
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

class SocialNewsHeroSidebar extends StatelessWidget {
  const SocialNewsHeroSidebar({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    final featured = category.articles.first;
    final rest = category.articles.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialNewsCategoryBar(category: category),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 16,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _FeaturedArticle(article: featured, color: category.color),
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Column(
                  children: [
                    for (final article in rest)
                      _ListTile(article: article, color: category.color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SocialNewsGrid4Col extends StatelessWidget {
  const SocialNewsGrid4Col({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialNewsCategoryBar(category: category),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final article in category.articles)
                SizedBox(
                  width: 170,
                  child: _GridCard(article: article, color: category.color),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SocialNewsFullCover extends StatelessWidget {
  const SocialNewsFullCover({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    final article = category.articles.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialNewsCategoryBar(category: category),
        Stack(
          children: [
            Container(
              height: 280,
              color: category.color,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: const Color(0xFFF57C00),
                      child: Text(
                        '${article.dateLabel}  ${article.commentCount} commenti',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SocialNewsMobileFeaturedList extends StatelessWidget {
  const SocialNewsMobileFeaturedList({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    final featured = category.articles.first;
    final rest = category.articles.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialNewsCategoryBar(category: category),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _FeaturedArticle(article: featured, color: category.color, compact: true),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            children: [
              for (final article in rest)
                _ListTile(article: article, color: category.color),
            ],
          ),
        ),
      ],
    );
  }
}

class SocialNewsMobileCategorySections extends StatelessWidget {
  const SocialNewsMobileCategorySections({super.key, required this.category});

  final SocialNewsPreviewCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialNewsCategoryBar(category: category),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            children: [
              for (final article in category.articles)
                _ListTile(article: article, color: category.color),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  const _FeaturedArticle({
    required this.article,
    required this.color,
    this.compact = false,
  });

  final SocialNewsPreviewArticle article;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: compact ? 180 : 220,
          width: double.infinity,
          color: color,
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
        if (article.lead != null) ...[
          const SizedBox(height: 8),
          Text(
            article.lead!,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.article, required this.color});

  final SocialNewsPreviewArticle article;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 72, height: 72, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.dateLabel,
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
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.article, required this.color});

  final SocialNewsPreviewArticle article;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 120, width: double.infinity, color: color),
        const SizedBox(height: 8),
        Text(
          article.dateLabel,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          article.title,
          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
        ),
      ],
    );
  }
}
