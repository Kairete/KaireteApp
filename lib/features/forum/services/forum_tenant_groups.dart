import 'package:kairete/features/forum/models/forum_node.dart';

/// Raggruppa i forum tenant sotto le Category XF (header sezione).
///
/// - Nasconde i Forum-root mappati con figli (es. "Juve Social")
/// - Header = Category più vicina sotto quel root (es. "Juventus Forum")
/// - Non sale a Category hub tipo "Sports Italia"
List<ForumNodeGroup> buildTenantForumGroups({
  required List<Map<String, dynamic>> rawNodes,
  required Set<int> mappedNodeIds,
}) {
  if (mappedNodeIds.isEmpty || rawNodes.isEmpty) return const [];

  final allNodes = <ForumNode>[];
  final breadcrumbsById = <int, List<Map<String, dynamic>>>{};
  // Ordine ACP: display_order tra fratelli; lft se presente (ordine albero XF).
  final displayOrderById = <int, int>{};
  final lftById = <int, int>{};
  var listIndex = 0;
  final listIndexById = <int, int>{};
  for (final raw in rawNodes) {
    final node = ForumNode.fromJson(raw);
    if (node.nodeId <= 0) continue;
    allNodes.add(node);
    displayOrderById[node.nodeId] = node.displayOrder;
    final lft = _asInt(raw['lft']);
    if (lft > 0) lftById[node.nodeId] = lft;
    listIndexById[node.nodeId] = listIndex++;
    final crumbs = raw['breadcrumbs'];
    if (crumbs is List) {
      breadcrumbsById[node.nodeId] = crumbs
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  final byId = {for (final n in allNodes) n.nodeId: n};

  int compareCategoryIds(int a, int b) {
    if (a <= 0 && b > 0) return 1;
    if (a > 0 && b <= 0) return -1;
    final la = lftById[a];
    final lb = lftById[b];
    if (la != null && lb != null && la != lb) return la.compareTo(lb);
    final oa = displayOrderById[a] ?? 0;
    final ob = displayOrderById[b] ?? 0;
    if (oa != ob) return oa.compareTo(ob);
    final ia = listIndexById[a] ?? a;
    final ib = listIndexById[b] ?? b;
    if (ia != ib) return ia.compareTo(ib);
    return a.compareTo(b);
  }

  bool underMappedRoot(ForumNode node) {
    if (mappedNodeIds.contains(node.nodeId)) return true;
    var parentId = node.parentNodeId;
    final seen = <int>{};
    while (parentId > 0 && seen.add(parentId)) {
      if (mappedNodeIds.contains(parentId)) return true;
      parentId = byId[parentId]?.parentNodeId ?? 0;
    }
    for (final crumb in breadcrumbsById[node.nodeId] ?? const []) {
      final id = _asInt(crumb['node_id']);
      if (id > 0 && mappedNodeIds.contains(id)) return true;
    }
    return false;
  }

  /// Solo Forum mappati con figli = contenitore indice (non Category).
  final indexForumRoots = mappedNodeIds.where((id) {
    final node = byId[id];
    if (node != null && !node.isForum) return false;
    return allNodes.any(
      (n) =>
          n.parentNodeId == id &&
          (n.isCategory || n.isForum) &&
          n.nodeId != id,
    );
  }).toSet();

  final forums = allNodes
      .where(
        (n) =>
            n.isForum &&
            underMappedRoot(n) &&
            !indexForumRoots.contains(n.nodeId),
      )
      .toList();
  if (forums.isEmpty) return const [];

  ({int id, String title})? categoryForForum(ForumNode forum) {
    final crumbs = breadcrumbsById[forum.nodeId] ?? const <Map<String, dynamic>>[];
    if (crumbs.isNotEmpty) {
      for (final crumb in crumbs.reversed) {
        final id = _asInt(crumb['node_id']);
        final type = crumb['node_type_id']?.toString() ?? '';
        // Usciti dal root mappato → non usare Category hub (Sports Italia).
        if (type == 'Forum' && indexForumRoots.contains(id)) {
          break;
        }
        if (type != 'Category') continue;
        final title = crumb['title']?.toString().trim() ?? '';
        if (id <= 0 || title.isEmpty) continue;
        return (id: id, title: title);
      }
    }

    var parentId = forum.parentNodeId;
    final seen = <int>{};
    while (parentId > 0 && seen.add(parentId)) {
      if (indexForumRoots.contains(parentId)) break;
      final parent = byId[parentId];
      if (parent == null) break;
      if (parent.isForum) break;
      if (parent.isCategory) {
        return (id: parent.nodeId, title: parent.title);
      }
      parentId = parent.parentNodeId;
    }
    return null;
  }

  final groupsByCategory = <int, ForumNodeGroup>{};
  final order = <int>[];

  for (final forum in forums) {
    final cat = categoryForForum(forum);
    final categoryId = cat?.id ?? 0;
    final title = (cat?.title.isNotEmpty == true) ? cat!.title : 'Forum';
    final existing = groupsByCategory[categoryId];
    if (existing == null) {
      groupsByCategory[categoryId] = ForumNodeGroup(
        categoryId: categoryId,
        title: title,
        forums: [forum],
      );
      order.add(categoryId);
    } else {
      groupsByCategory[categoryId] = ForumNodeGroup(
        categoryId: existing.categoryId,
        title: existing.title,
        forums: [...existing.forums, forum],
      );
    }
  }

  for (final rootId in indexForumRoots) {
    for (final n in allNodes) {
      if (!n.isCategory || n.parentNodeId != rootId) continue;
      if (groupsByCategory.containsKey(n.nodeId)) continue;
      groupsByCategory[n.nodeId] = ForumNodeGroup(
        categoryId: n.nodeId,
        title: n.title,
        forums: const [],
      );
      order.add(n.nodeId);
    }
  }

  final groups = <ForumNodeGroup>[];
  for (final id in order) {
    final g = groupsByCategory[id];
    if (g == null) continue;
    final forumsSorted = [...g.forums]..sort((a, b) {
        final byLft = (lftById[a.nodeId] ?? 0).compareTo(lftById[b.nodeId] ?? 0);
        if (lftById.containsKey(a.nodeId) && lftById.containsKey(b.nodeId) && byLft != 0) {
          return byLft;
        }
        final o = a.displayOrder.compareTo(b.displayOrder);
        if (o != 0) return o;
        return a.nodeId.compareTo(b.nodeId);
      });
    groups.add(ForumNodeGroup(
      categoryId: g.categoryId,
      title: g.title,
      forums: forumsSorted,
    ));
  }

  // Ordine categorie = lft / display_order ACP (non alfabetico).
  groups.sort((a, b) => compareCategoryIds(a.categoryId, b.categoryId));

  return groups;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
