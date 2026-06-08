import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/blog/models/blog_compose_options.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

enum _ComposeMode { feed, blog }

class OmnifeedComposeBar extends StatefulWidget {
  const OmnifeedComposeBar({
    super.key,
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  State<OmnifeedComposeBar> createState() => _OmnifeedComposeBarState();
}

class _OmnifeedComposeBarState extends State<OmnifeedComposeBar> {
  final _messageCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _feedService = OmnifeedService();
  final _blogService = BlogService();

  _ComposeMode _mode = _ComposeMode.feed;
  bool _isRefreshing = false;
  bool _isPosting = false;
  bool _blogOptionsLoading = false;
  bool _blogOptionsLoaded = false;

  List<WritableBlog> _blogs = [];
  List<BlogCategoryOption> _categories = [];
  int? _selectedBlogId;
  int? _selectedCategoryId;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  bool get _canPublish {
    if (_isPosting) return false;
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) return false;
    if (_mode == _ComposeMode.feed) return true;
    return _titleCtrl.text.trim().isNotEmpty &&
        (_selectedBlogId ?? 0) > 0 &&
        _blogOptionsLoaded;
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _ensureBlogOptions() async {
    if (_blogOptionsLoaded || _blogOptionsLoading) return;
    setState(() => _blogOptionsLoading = true);
    try {
      final results = await Future.wait([
        _blogService.fetchWritableBlogs(),
        _blogService.fetchCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _blogs = results[0] as List<WritableBlog>;
        _categories = results[1] as List<BlogCategoryOption>;
        if (_blogs.isNotEmpty) {
          _selectedBlogId ??= _blogs.first.blogId;
        }
        _blogOptionsLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        AppToast.error('Impossibile caricare i blog.');
      }
    } finally {
      if (mounted) setState(() => _blogOptionsLoading = false);
    }
  }

  Future<void> _setMode(_ComposeMode mode) async {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    if (mode == _ComposeMode.blog) {
      await _ensureBlogOptions();
    }
    if (mounted) setState(() {});
  }

  Future<void> _publish() async {
    if (!_canPublish) return;

    setState(() => _isPosting = true);
    try {
      final wasBlog = _mode == _ComposeMode.blog;
      if (wasBlog) {
        final blogId = _selectedBlogId;
        if (blogId == null || blogId <= 0) {
          AppToast.error('Seleziona un blog.');
          return;
        }
        await _feedService.createBlogPost(
          blogId: blogId,
          title: _titleCtrl.text,
          message: _messageCtrl.text,
          categoryId: _selectedCategoryId ?? 0,
          tags: _tagsCtrl.text,
        );
      } else {
        await _feedService.createProfilePost(message: _messageCtrl.text);
      }

      _messageCtrl.clear();
      _titleCtrl.clear();
      _tagsCtrl.clear();
      if (wasBlog) {
        setState(() => _mode = _ComposeMode.feed);
      }
      AppToast.success(
        wasBlog ? 'Articolo pubblicato.' : 'Post pubblicato.',
      );
      await widget.onRefresh();
    } on OmnifeedException catch (e) {
      AppToast.error(e.message);
    } on BlogException catch (e) {
      AppToast.error(e.message);
    } catch (_) {
      AppToast.error('Pubblicazione non riuscita.');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlog = _mode == _ComposeMode.blog;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.composeBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isBlog) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: TextField(
                    controller: _titleCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: EdgeInsets.fromLTRB(12, isBlog ? 0 : 10, 12, 0),
                child: TextField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  minLines: 2,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: isBlog
                        ? 'Testo articolo…'
                        : 'Scrivi qualcosa…',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isBlog) ...[
                if (_blogOptionsLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (_blogOptionsLoaded) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Column(
                      children: [
                        if (_categories.isNotEmpty)
                          DropdownButtonFormField<int?>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('— Nessuna —'),
                              ),
                              ..._categories.map(
                                (cat) => DropdownMenuItem<int?>(
                                  value: cat.categoryId,
                                  child: Text(cat.title),
                                ),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedCategoryId = v),
                          ),
                        if (_categories.isNotEmpty) const SizedBox(height: 8),
                        TextField(
                          controller: _tagsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tag',
                            hintText: 'Separati da virgola',
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                        if (_blogs.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedBlogId,
                            decoration: const InputDecoration(
                              labelText: 'Blog',
                              isDense: true,
                            ),
                            items: _blogs
                                .map(
                                  (blog) => DropdownMenuItem<int>(
                                    value: blog.blogId,
                                    child: Text(blog.title),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBlogId = v),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.feedFooterBg,
                  border: Border(
                    top: BorderSide(color: AppTheme.cardBorder, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Aggiorna feed',
                      onPressed: _isRefreshing ? null : _refresh,
                      icon: _isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync, color: AppTheme.linkBlue),
                    ),
                    const Spacer(),
                    _ModeButton(
                      label: 'Feed',
                      icon: Icons.article_outlined,
                      selected: !isBlog,
                      onTap: () => _setMode(_ComposeMode.feed),
                    ),
                    const SizedBox(width: 6),
                    _ModeButton(
                      label: 'Blog',
                      icon: Icons.rss_feed,
                      selected: isBlog,
                      highlight: true,
                      onTap: () => _setMode(_ComposeMode.blog),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _canPublish ? _publish : null,
                      icon: _isPosting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_outlined, size: 16),
                      label: const Text('Pubblica'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (highlight ? const Color(0xFFE6A800) : AppTheme.linkBlue)
        : (highlight ? const Color(0xFFFFF6DF) : Colors.white);
    final fg = selected
        ? Colors.white
        : (highlight ? const Color(0xFF7A4E00) : AppTheme.textSecondary);
    final border = selected
        ? (highlight ? const Color(0xFFC89200) : AppTheme.linkBlue)
        : (highlight ? const Color(0xFFE6A800) : AppTheme.cardBorder);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
