import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class OmnifeedCard extends StatelessWidget {
  const OmnifeedCard({
    super.key,
    required this.item,
    this.onTap,
    this.onReact,
  });

  final OmnifeedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final author = item.author;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(url: author?.avatarUrl, name: author?.label),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author?.label ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          [
                            item.typeLabel,
                            if (item.categoryLabel != null) item.categoryLabel,
                            formatOmnifeedDate(item.itemDate),
                          ].where((e) => e != null && e.toString().isNotEmpty).join(' · '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.displayTitle.isNotEmpty &&
                  item.displayTitle != item.displayBody) ...[
                const SizedBox(height: 10),
                Text(
                  item.displayTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                item.displayBody,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onReact,
                    icon: const Icon(Icons.favorite_border, size: 20),
                  ),
                  Text('${item.reactionScore}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 18),
                  const SizedBox(width: 4),
                  Text('${item.commentCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.name});

  final String? url;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primary.withOpacity(0.15),
      child: Text(initial, style: const TextStyle(color: AppTheme.primary)),
    );
  }
}
