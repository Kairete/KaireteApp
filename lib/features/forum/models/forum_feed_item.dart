import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';

/// Elemento della lista forum: discussione nativa oppure articolo blog collegato.
class ForumFeedItem {
  const ForumFeedItem.thread(this.thread) : blogEntry = null;
  const ForumFeedItem.blog(this.blogEntry) : thread = null;

  final ForumThread? thread;
  final BlogEntry? blogEntry;

  bool get isBlog => blogEntry != null;
  bool get isThread => thread != null;

  int get sortDate {
    if (blogEntry != null) return blogEntry!.postDate ?? 0;
    return thread?.postDate ?? 0;
  }
}
