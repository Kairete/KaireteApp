/// Layout nidificazione commenti: il grigio parte dalla colonna testo del padre.
class FeedCommentLayout {
  FeedCommentLayout._();

  static const avatarSize = 26.0;
  static const avatarGap = 6.0;
  static const rootAvatarSize = 32.0;
  static const rootAvatarGap = 8.0;

  /// Inset dalla riga perimetrale sinistra della scheda (solo respiro avatar).
  static const cardInsetLeft = 4.0;
  static const cardInsetRight = 10.0;

  static const nestedTilePaddingLeft = 6.0;
  static const nestedTilePaddingTop = 5.0;
  static const nestedTilePaddingRight = 8.0;
  static const nestedTilePaddingBottom = 5.0;

  /// Margine destro del riquadro grigio (non fino al bordo card).
  static const nestedRightInset = 10.0;

  /// Il grigio parte dalla prima lettera del testo del padre.
  static double marginForDepth(int depth) {
    if (depth <= 0) return 0;
    var margin = rootAvatarSize + rootAvatarGap;
    for (var i = 1; i < depth; i++) {
      margin += nestedTilePaddingLeft + avatarSize + avatarGap;
    }
    return margin;
  }
}

class FeedCommentTreeNode {
  FeedCommentTreeNode({
    required this.id,
    required this.parentId,
    required this.depth,
  });

  final int id;
  final int parentId;
  final int depth;
}

/// Appiattisce commenti con parent in ordine cronologico DFS.
List<FeedCommentTreeNode> flattenFeedComments({
  required List<int> ids,
  required List<int> parentIds,
  int maxDepth = 8,
}) {
  if (ids.isEmpty) return const [];

  final byId = <int, int>{};
  final children = <int, List<int>>{};
  final roots = <int>[];

  for (var i = 0; i < ids.length; i++) {
    final id = ids[i];
    final parentId = parentIds[i];
    byId[id] = parentId;
    if (parentId > 0 && parentId != id && ids.contains(parentId)) {
      children.putIfAbsent(parentId, () => []).add(id);
    } else {
      roots.add(id);
    }
  }

  void sortIds(List<int> list) {
    list.sort((a, b) {
      final ai = ids.indexOf(a);
      final bi = ids.indexOf(b);
      return ai.compareTo(bi);
    });
  }

  sortIds(roots);
  for (final list in children.values) {
    sortIds(list);
  }

  final out = <FeedCommentTreeNode>[];

  void walk(List<int> nodes, int depth) {
    if (depth > maxDepth) return;
    for (final id in nodes) {
      out.add(
        FeedCommentTreeNode(
          id: id,
          parentId: byId[id] ?? 0,
          depth: depth,
        ),
      );
      final kids = children[id];
      if (kids != null && kids.isNotEmpty) {
        walk(kids, depth + 1);
      }
    }
  }

  walk(roots, 0);

  // Commenti orfani (parent mancante): livello 0 in ordine originale.
  final seen = out.map((e) => e.id).toSet();
  for (var i = 0; i < ids.length; i++) {
    final id = ids[i];
    if (seen.contains(id)) continue;
    out.add(
      FeedCommentTreeNode(
        id: id,
        parentId: parentIds[i],
        depth: 0,
      ),
    );
  }

  return out;
}

/// Profondità per id dopo appiattimento del thread.
Map<int, int> depthByCommentId({
  required List<int> ids,
  required List<int> parentIds,
}) {
  final tree = flattenFeedComments(ids: ids, parentIds: parentIds);
  return {for (final node in tree) node.id: node.depth};
}

/// Limite massimo livelli di risposta annidata.
bool nestedCommentCanReply(int depth) => depth >= 0 && depth < 8;
