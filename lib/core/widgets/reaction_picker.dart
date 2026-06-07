import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/core/models/reaction_icon.dart';
import 'package:kairete/core/services/reaction_catalog.dart';

typedef ReactionSelected = Future<void> Function(int reactionId);

/// Mostra il picker XenForo e invoca [onSelected] con la reazione scelta.
Future<void> pickReactionAndApply(
  BuildContext context,
  ReactionSelected onSelected,
) async {
  await ReactionCatalog.instance.ensureLoaded();
  final icons = ReactionCatalog.instance.icons;
  if (!context.mounted) return;

  if (icons.isEmpty) {
    await onSelected(1);
    return;
  }

  final reactionId = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ReactionPickerSheet(icons: icons),
  );
  if (reactionId != null && reactionId > 0) {
    await onSelected(reactionId);
  }
}

class _ReactionPickerSheet extends StatelessWidget {
  const _ReactionPickerSheet({required this.icons});

  final List<ReactionIcon> icons;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: icons
                  .map(
                    (icon) => InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(context, icon.reactionId),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CachedNetworkImage(
                              imageUrl: icon.imageUrl,
                              width: 32,
                              height: 32,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.emoji_emotions_outlined,
                                size: 32,
                              ),
                            ),
                            if (icon.title.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                icon.title,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
