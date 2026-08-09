import 'package:flutter/material.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/social_news/models/social_news_models.dart';

class SocialNewsException implements Exception {
  SocialNewsException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SocialNewsService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<SocialNewsHomepage> fetchHomepage({String? publicationSlug}) async {
    await AppApi.instance.applySession();
    final query = <String, dynamic>{};
    if (publicationSlug != null && publicationSlug.trim().isNotEmpty) {
      query['publication_slug'] = publicationSlug.trim();
    }

    Object? lastError;
    for (final path in [
      ApiPaths.socialNewsHomepage,
      ApiPaths.socialNewsHomepageLegacy,
    ]) {
      try {
        final json = await _api.get(path, query: query);
        _throwIfError(json);
        return SocialNewsHomepage.fromJson(json);
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is SocialNewsException) throw lastError;
    throw SocialNewsException('Impossibile caricare Social News.');
  }

  Future<SocialNewsArticle> fetchArticle(
    int articleId, {
    int? itemId,
  }) async {
    await AppApi.instance.applySession();

    Object? lastError;
    for (final path in [
      ApiPaths.socialNewsArticle(articleId),
      ApiPaths.socialNewsArticleLegacy(articleId),
    ]) {
      try {
        final json = await _api.get(path);
        _throwIfError(json);
        final raw = json['article'];
        if (raw is Map) {
          return SocialNewsArticle.fromJson(Map<String, dynamic>.from(raw));
        }
      } catch (e) {
        lastError = e;
      }
    }

    final encodedItemId = itemId ??
        (articleId > 0
            ? OmnifeedItemId.encode(
                OmnifeedItemId.typeSocialNewsArticle,
                articleId,
              )
            : 0);
    if (encodedItemId > 0) {
      try {
        final item = await OmnifeedService().fetchItemDetail(encodedItemId);
        return _articleFromFeedItem(item);
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is SocialNewsException) throw lastError;
    throw SocialNewsException('Articolo non trovato.');
  }

  SocialNewsArticle _articleFromFeedItem(OmnifeedItem item) {
    final categoryTitle = item.categoryLabel?.trim();
    return SocialNewsArticle(
      articleId: item.nativeContentId,
      title: item.contentTitle ?? item.moduleTitle,
      slug: '',
      lead: '',
      previewText: item.listPreviewBody,
      message: item.displayBody,
      messageHtml: item.messageParsed ?? '',
      articleDate: item.itemDate ?? 0,
      commentCount: item.commentCount,
      reactionScore: item.reactionScore,
      viewUrl: item.viewUrl ?? '',
      category: categoryTitle != null && categoryTitle.isNotEmpty
          ? SocialNewsCategory(
              categoryId: 0,
              title: categoryTitle,
              slug: '',
              headerColor: const Color(0xFF333333),
            )
          : null,
    );
  }

  void _throwIfError(Map<String, dynamic> json) {
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map) {
        final message = (first['message'] as String?)?.trim();
        if (message != null && message.isNotEmpty) {
          throw SocialNewsException(message);
        }
      }
      throw SocialNewsException('Errore API Social News.');
    }
  }
}
