import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/blog/widgets/blog_entry_body.dart';
import 'package:kairete/features/blog/widgets/blog_feed_card.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage({super.key, required this.entryId});

  final int entryId;

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final BlogService _service = BlogService();
  BlogEntry? _entry;
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
      final entry = await _service
          .fetchEntry(widget.entryId)
          .timeout(const Duration(seconds: 25));
      if (!mounted) return;
      setState(() {
        _entry = entry;
        _loading = false;
      });
    } on TimeoutException {
      _fail('Il caricamento impiega troppo tempo. Riprova.');
    } on BlogException catch (e) {
      _fail(e.message);
    } on DioException catch (e) {
      _fail(XenforoApi.connectionMessage(e));
    } catch (_) {
      _fail('Impossibile caricare il blogpost.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  Future<void> _react() async {
    final entry = _entry;
    if (entry == null) return;
    try {
      await _service.react(blogEntryId: entry.blogEntryId);
      await _load();
    } on BlogException catch (e) {
      Get.snackbar('Errore', e.message);
    }
  }

  void _openBlogFilter() {
    final entry = _entry;
    if (entry == null) return;
    final blogId = entry.blog?.blogId;
    if (blogId == null || blogId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterBlogId: blogId,
        pageTitle: entry.blog?.title ?? 'Blog',
      ),
    );
  }

  void _openCategoryFilter() {
    final entry = _entry;
    if (entry == null) return;
    final categoryId = entry.category?.categoryId;
    if (categoryId == null || categoryId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterCategoryId: categoryId,
        pageTitle: entry.category?.title ?? 'Categoria',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Blog'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : _entry == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FeedCardShell(
                        header: BlogFeedHeader(
                          entry: _entry!,
                          onBlogTap: _openBlogFilter,
                          onCategoryTap: _openCategoryFilter,
                        ),
                        body: BlogEntryBody(entry: _entry!),
                        footer: FeedCardActionBar(
                          commentCount: _entry!.commentCount,
                          onComment: () {},
                          onReact: _react,
                        ),
                      ),
                    ),
    );
  }
}
