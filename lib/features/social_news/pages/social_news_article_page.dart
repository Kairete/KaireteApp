import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';
import 'package:kairete/features/social_news/models/social_news_models.dart';
import 'package:kairete/features/social_news/services/social_news_service.dart';
import 'package:kairete/features/social_news/widgets/social_news_home_widgets.dart';

class SocialNewsArticlePage extends StatefulWidget {
  const SocialNewsArticlePage({
    super.key,
    required this.articleId,
    this.itemId,
  });

  final int articleId;
  final int? itemId;

  @override
  State<SocialNewsArticlePage> createState() => _SocialNewsArticlePageState();
}

class _SocialNewsArticlePageState extends State<SocialNewsArticlePage> {
  final SocialNewsService _service = SocialNewsService();
  SocialNewsArticle? _article;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final article = await _service.fetchArticle(
        widget.articleId,
        itemId: widget.itemId,
      );
      if (!mounted) return;
      setState(() {
        _article = article;
        _loading = false;
      });
    } on SocialNewsException catch (e) {
      _fail(e.message);
    } catch (_) {
      _fail('Impossibile caricare l\'articolo.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_article?.category?.title ?? 'Articolo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _buildBody(_article!),
    );
  }

  Widget _buildBody(SocialNewsArticle article) {
    final category = article.category;
    final html = article.messageHtml.trim();
    final plain = article.message.trim();
    final lead = article.lead.trim();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (category != null) SocialNewsCategoryBar(category: category),
          Container(
            height: 220,
            width: double.infinity,
            color: article.headerColor,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatFeedRelativeDate(article.articleDate),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (lead.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    lead,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (html.isNotEmpty)
                  Html(data: html)
                else if (plain.isNotEmpty)
                  Text(plain, style: const TextStyle(height: 1.5, fontSize: 15))
                else
                  Text(
                    'Nessun contenuto.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                if (article.commentCount > 0) ...[
                  const SizedBox(height: 20),
                  Text(
                    '${article.commentCount} commenti',
                    style: TextStyle(
                      color: AppTheme.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
