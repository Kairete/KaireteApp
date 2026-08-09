import 'package:flutter/material.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/social_news/models/social_news_models.dart';

extension SocialNewsArticleFeedMapper on SocialNewsArticle {
  OmnifeedItem toFeedItem() {
    final id = articleId;
    final categoryTitle = category?.title.trim();
    final preview = previewText.isNotEmpty
        ? previewText
        : (lead.isNotEmpty ? lead : message);
    final parsed = messageHtml.isNotEmpty
        ? messageHtml
        : (message.isNotEmpty ? message : preview);
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(OmnifeedItemId.typeSocialNewsArticle, id),
      contentType: 'social_news_article',
      contentId: id,
      contentTitle: title,
      messagePlainText: preview,
      messageParsed: parsed,
      itemDate: articleDate,
      commentCount: commentCount,
      reactionScore: reactionScore,
      categoryLabel:
          categoryTitle != null && categoryTitle.isNotEmpty ? categoryTitle : null,
      categoryHeaderColor: _colorToHex(headerColor),
      viewUrl: viewUrl,
      mediaThumbnailUrl: coverUrl.isNotEmpty ? coverUrl : null,
      tags: tags,
    );
  }

  String _colorToHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }
}

extension SocialNewsHomepageFeedMapper on SocialNewsHomepage {
  List<OmnifeedItem> toFeedItems() {
    final items = <OmnifeedItem>[];
    for (final block in blocks) {
      final featured = block.featured;
      if (featured != null) {
        items.add(featured.toFeedItem());
      }
      for (final article in block.articles) {
        items.add(article.toFeedItem());
      }
    }
    return items;
  }
}
