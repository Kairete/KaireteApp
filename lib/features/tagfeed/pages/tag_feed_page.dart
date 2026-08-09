import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_card.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/tagfeed/controllers/tagfeed_controller.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class TagFeedPage extends StatelessWidget {
  const TagFeedPage({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TagFeedController(tag: tag), tag: tag);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final label = c.tagLabel.value.trim();
          final display = label.isNotEmpty ? label : tag;
          return Text('#$display');
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
        if (c.isLoading.value && c.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.errorMessage.value.isNotEmpty && c.items.isEmpty) {
          return _ErrorState(
            message: c.errorMessage.value,
            onRetry: c.loadFeed,
          );
        }
        return RefreshIndicator(
          onRefresh: c.loadFeed,
          child: c.items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Nessun contenuto per questo tag.')),
                  ],
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      c.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: c.items.length,
                    itemBuilder: (_, i) {
                      final item = c.items[i];
                      return OmnifeedFeedCard(
                        key: ValueKey(item.itemId),
                        item: item,
                        onOpen: () => c.openDetail(item),
                        onComment: () => c.openDetail(item),
                        onAuthorTap: () => c.openAuthor(item),
                        onBlogTap: item.contentType == 'ubs_blog_entry'
                            ? () => c.openBlog(item)
                            : null,
                        onForumTap: item.contentType == 'thread'
                            ? () => c.openForum(item)
                            : null,
                        onGroupTap: item.contentType == 'tl_group_post'
                            ? () => OmnifeedNavigation.openGroup(item)
                            : null,
                        onMediaTap: item.contentType == 'xfmg_media'
                            ? () => OmnifeedNavigation.openMediaAlbum(item)
                            : null,
                        onMediaCategoryTap: item.contentType == 'xfmg_media'
                            ? () => OmnifeedNavigation.openMediaCategory(item)
                            : null,
                        onReact: (reactionId) =>
                            c.react(item, reactionId: reactionId),
                        onBookmark: () => c.toggleBookmark(item),
                        onShareInternal: () async {
                          final result = await showFeedShareInternal(
                            context: context,
                            itemId: item.itemId,
                            previewText:
                                item.messagePlainText ?? item.contentTitle,
                          );
                          if (result != null) {
                            c.applyShareResult(item.itemId, result);
                          }
                        },
                        onShareExternal: () async {
                          final result = await showFeedShareExternal(
                            context: context,
                            itemId: item.itemId,
                            viewUrl: item.viewUrl,
                          );
                          if (result != null) {
                            c.applyShareResult(item.itemId, result);
                          }
                        },
                        onTagTap: TagFeedNavigation.openTag,
                        showOwnerActions: c.isOwnedByCurrentUser(item),
                        onEdit: () => c.editItem(item),
                        onDelete: () => c.deleteItem(item),
                        onCommentsChanged: c.loadFeed,
                      );
                    },
                  ),
                ),
        );
      }),
          ),
          const FeedInlineReplyBar(),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
