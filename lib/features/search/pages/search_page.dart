import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/search/controllers/search_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final AppSearchController _c;
  late final TextEditingController _text;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _c = Get.put(AppSearchController(), tag: 'app_search');
    _text = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _c.submit(widget.initialQuery);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    if (Get.isRegistered<AppSearchController>(tag: 'app_search')) {
      Get.delete<AppSearchController>(tag: 'app_search');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: TextField(
          controller: _text,
          focusNode: _focus,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cerca su Kairete…',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _c.onQueryChanged,
          onSubmitted: _c.submit,
        ),
        actions: [
          IconButton(
            tooltip: 'Cerca',
            icon: const Icon(Icons.search),
            onPressed: () => _c.submit(_text.text),
          ),
          IconButton(
            tooltip: 'Cancella',
            icon: const Icon(Icons.close),
            onPressed: () {
              _text.clear();
              _c.onQueryChanged('');
              _focus.requestFocus();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_c.isSearching.value && _c.results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_c.showSuggestions) {
          return _SuggestionsBody(controller: _c);
        }

        if (_c.hasSearched.value) {
          return _ResultsBody(controller: _c);
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Cerca discussioni, media, articoli e membri.\nDigita almeno 2 caratteri per i suggerimenti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
        );
      }),
    );
  }
}

class _SuggestionsBody extends StatelessWidget {
  const _SuggestionsBody({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (controller.isSuggesting.value)
          const LinearProgressIndicator(minHeight: 2),
        if (controller.users.isNotEmpty) ...[
          const _SectionHeader('Membri'),
          ...controller.users.map(
            (u) => ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.cardBorder,
                backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(u.avatarUrl!)
                    : null,
                child: u.avatarUrl == null || u.avatarUrl!.isEmpty
                    ? Text(
                        u.username.isNotEmpty
                            ? u.username[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              title: Text(u.username),
              onTap: () => controller.openUser(u),
            ),
          ),
        ],
        if (controller.suggestions.isNotEmpty) ...[
          const _SectionHeader('Suggerimenti'),
          ...controller.suggestions.map(
            (s) => ListTile(
              leading: Icon(_iconForType(s.contentType), color: AppTheme.primary),
              title: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: s.desc.isNotEmpty
                  ? Text(
                      s.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : (s.typeLabel.isNotEmpty ? Text(s.typeLabel) : null),
              onTap: () => controller.openSuggestion(s),
            ),
          ),
        ],
        if (!controller.isSuggesting.value &&
            controller.users.isEmpty &&
            controller.suggestions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nessun suggerimento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.search, color: AppTheme.linkBlue),
          title: Text('Cerca “${controller.query.value.trim()}”'),
          onTap: () => controller.submit(),
        ),
      ],
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.controller});

  final AppSearchController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.results;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Nessun risultato.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                '${controller.resultCount.value} risultati per “${controller.query.value.trim()}”',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          final item = items[i - 1];
          return ListTile(
            leading: Icon(_iconForType(item.type), color: AppTheme.primary),
            title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelForType(item.type) +
                      (item.username.isNotEmpty ? ' · ${item.username}' : ''),
                  style: const TextStyle(fontSize: 12),
                ),
                if (item.snippet.isNotEmpty)
                  Text(
                    item.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
              ],
            ),
            isThreeLine: item.snippet.isNotEmpty,
            onTap: () => controller.openResult(item),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'thread':
    case 'post':
      return Icons.forum_outlined;
    case 'xfmg_media':
    case 'media':
      return Icons.photo_outlined;
    case 'ubs_blog_entry':
    case 'blog_entry':
      return Icons.article_outlined;
    case 'profile_post':
      return Icons.person_outline;
    case 'user':
    case 'member':
      return Icons.person;
    default:
      return Icons.search;
  }
}

String _labelForType(String type) {
  switch (type) {
    case 'thread':
      return 'Discussione';
    case 'post':
      return 'Messaggio';
    case 'xfmg_media':
    case 'media':
      return 'Media';
    case 'ubs_blog_entry':
    case 'blog_entry':
      return 'Blog';
    case 'profile_post':
      return 'Post profilo';
    default:
      return type;
  }
}
