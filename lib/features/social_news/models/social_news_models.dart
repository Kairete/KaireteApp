import 'package:flutter/material.dart';
import 'package:kairete/core/utils/json_parse.dart';

class SocialNewsPublication {
  SocialNewsPublication({
    required this.publicationId,
    required this.title,
    required this.slug,
    this.description = '',
  });

  final int publicationId;
  final String title;
  final String slug;
  final String description;

  factory SocialNewsPublication.fromJson(Map<String, dynamic> json) {
    return SocialNewsPublication(
      publicationId: JsonParse.intValue(json['publication_id']),
      title: (json['title'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
    );
  }
}

class SocialNewsCategory {
  SocialNewsCategory({
    required this.categoryId,
    required this.title,
    required this.slug,
    required this.headerColor,
    this.layoutMobile = 'featured_list',
  });

  final int categoryId;
  final String title;
  final String slug;
  final Color headerColor;
  final String layoutMobile;

  factory SocialNewsCategory.fromJson(Map<String, dynamic> json) {
    return SocialNewsCategory(
      categoryId: JsonParse.intValue(json['category_id']),
      title: (json['title'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      headerColor: _colorFromHex(json['header_color'] as String?),
      layoutMobile: (json['layout_mobile'] as String?)?.trim() ?? 'featured_list',
    );
  }

  static Color _colorFromHex(String? raw) {
    var hex = (raw ?? '#333333').trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFF333333);
    return Color(value);
  }
}

class SocialNewsArticle {
  SocialNewsArticle({
    required this.articleId,
    required this.title,
    required this.slug,
    this.lead = '',
    this.previewText = '',
    this.message = '',
    this.messageHtml = '',
    this.articleDate = 0,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.viewUrl = '',
    this.coverUrl = '',
    this.tags = const [],
    this.headerColor = const Color(0xFF333333),
    this.category,
    this.publication,
  });

  final int articleId;
  final String title;
  final String slug;
  final String lead;
  final String previewText;
  final String message;
  final String messageHtml;
  final int articleDate;
  final int commentCount;
  final int reactionScore;
  final String viewUrl;
  final String coverUrl;
  final List<String> tags;
  final Color headerColor;
  final SocialNewsCategory? category;
  final SocialNewsPublication? publication;

  factory SocialNewsArticle.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'];
    final publicationRaw = json['publication'];
    return SocialNewsArticle(
      articleId: JsonParse.intValue(json['article_id']),
      title: (json['title'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      lead: (json['lead'] as String?)?.trim() ?? '',
      previewText: (json['preview_text'] as String?)?.trim() ?? '',
      message: (json['message'] as String?)?.trim() ?? '',
      messageHtml: (json['message_html'] as String?)?.trim() ?? '',
      articleDate: JsonParse.intValue(json['article_date']),
      commentCount: JsonParse.intValue(json['comment_count']),
      reactionScore: JsonParse.intValue(json['reaction_score']),
      viewUrl: (json['view_url'] as String?)?.trim() ?? '',
      coverUrl: (json['cover_url'] as String?)?.trim() ?? '',
      tags: _parseTags(json['tags']),
      headerColor: SocialNewsCategory._colorFromHex(json['header_color'] as String?),
      category: categoryRaw is Map
          ? SocialNewsCategory.fromJson(Map<String, dynamic>.from(categoryRaw))
          : null,
      publication: publicationRaw is Map
          ? SocialNewsPublication.fromJson(Map<String, dynamic>.from(publicationRaw))
          : null,
    );
  }

  static List<String> _parseTags(Object? raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return const [];
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

class SocialNewsHomeBlock {
  SocialNewsHomeBlock({
    required this.category,
    required this.layoutMobile,
    this.featured,
    this.articles = const [],
    this.categoryUrl = '',
  });

  final SocialNewsCategory category;
  final String layoutMobile;
  final SocialNewsArticle? featured;
  final List<SocialNewsArticle> articles;
  final String categoryUrl;

  factory SocialNewsHomeBlock.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'];
    final featuredRaw = json['featured'];
    final articlesRaw = json['articles'] as List<dynamic>? ?? [];
    return SocialNewsHomeBlock(
      category: categoryRaw is Map
          ? SocialNewsCategory.fromJson(Map<String, dynamic>.from(categoryRaw))
          : SocialNewsCategory(
              categoryId: 0,
              title: '',
              slug: '',
              headerColor: const Color(0xFF333333),
            ),
      layoutMobile: (json['layout_mobile'] as String?)?.trim() ?? 'featured_list',
      featured: featuredRaw is Map
          ? SocialNewsArticle.fromJson(Map<String, dynamic>.from(featuredRaw))
          : null,
      articles: articlesRaw
          .whereType<Map>()
          .map((e) => SocialNewsArticle.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      categoryUrl: (json['category_url'] as String?)?.trim() ?? '',
    );
  }
}

class SocialNewsHomepage {
  SocialNewsHomepage({
    required this.publication,
    this.blocks = const [],
  });

  final SocialNewsPublication publication;
  final List<SocialNewsHomeBlock> blocks;

  factory SocialNewsHomepage.fromJson(Map<String, dynamic> json) {
    final pubRaw = json['publication'];
    final blocksRaw = json['blocks'] as List<dynamic>? ?? [];
    return SocialNewsHomepage(
      publication: pubRaw is Map
          ? SocialNewsPublication.fromJson(Map<String, dynamic>.from(pubRaw))
          : SocialNewsPublication(publicationId: 0, title: '', slug: ''),
      blocks: blocksRaw
          .whereType<Map>()
          .map((e) => SocialNewsHomeBlock.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
