import 'package:kairete/features/feed/models/author_signature_fields.dart';

class ForumAuthor {
  ForumAuthor({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
    this.signatureHtml,
    this.signaturePlain,
    this.contentShowSignature = true,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;
  final String? signatureHtml;
  final String? signaturePlain;
  final bool contentShowSignature;

  String get label =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;

  bool get hasVisibleSignature {
    if (!contentShowSignature) return false;
    final html = signatureHtml?.trim() ?? '';
    final plain = signaturePlain?.trim() ?? '';
    return html.isNotEmpty || plain.isNotEmpty;
  }

  factory ForumAuthor.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final urls = json['avatar_urls'];
    if (urls is Map) {
      avatar = urls['m']?.toString() ?? urls['s']?.toString();
    }
    final sig = AuthorSignatureFields.fromJson(json);
    return ForumAuthor(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      signatureHtml: sig.signatureHtml,
      signaturePlain: sig.signaturePlain,
      contentShowSignature: sig.contentShowSignature,
    );
  }
}

class ForumNodeTypeData {
  ForumNodeTypeData({
    this.discussionCount = 0,
    this.messageCount = 0,
    this.lastThreadTitle,
    this.lastPostDate,
    this.lastPostUsername,
  });

  final int discussionCount;
  final int messageCount;
  final String? lastThreadTitle;
  final int? lastPostDate;
  final String? lastPostUsername;

  factory ForumNodeTypeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ForumNodeTypeData();
    return ForumNodeTypeData(
      discussionCount: json['discussion_count'] as int? ?? 0,
      messageCount: json['message_count'] as int? ?? 0,
      lastThreadTitle: json['last_thread_title']?.toString(),
      lastPostDate: json['last_post_date'] as int?,
      lastPostUsername: json['last_post_username']?.toString(),
    );
  }
}

class ForumNode {
  ForumNode({
    required this.nodeId,
    required this.title,
    required this.nodeTypeId,
    this.parentNodeId = 0,
    this.displayOrder = 0,
    this.description,
    this.viewUrl,
    this.typeData,
    this.subForums = const [],
  });

  final int nodeId;
  final String title;
  final String nodeTypeId;
  final int parentNodeId;
  final int displayOrder;
  final String? description;
  final String? viewUrl;
  final ForumNodeTypeData? typeData;
  final List<ForumNode> subForums;

  bool get isCategory => nodeTypeId == 'Category';
  bool get isForum => nodeTypeId == 'Forum';

  ForumNode copyWith({List<ForumNode>? subForums}) {
    return ForumNode(
      nodeId: nodeId,
      title: title,
      nodeTypeId: nodeTypeId,
      parentNodeId: parentNodeId,
      displayOrder: displayOrder,
      description: description,
      viewUrl: viewUrl,
      typeData: typeData,
      subForums: subForums ?? this.subForums,
    );
  }

  factory ForumNode.fromJson(Map<String, dynamic> json) {
    return ForumNode(
      nodeId: json['node_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      nodeTypeId: json['node_type_id']?.toString() ?? '',
      parentNodeId: json['parent_node_id'] as int? ?? 0,
      displayOrder: json['display_order'] as int? ?? 0,
      description: json['description']?.toString(),
      viewUrl: json['view_url']?.toString(),
      typeData: ForumNodeTypeData.fromJson(
        json['type_data'] as Map<String, dynamic>?,
      ),
    );
  }
}

class ForumNodeGroup {
  ForumNodeGroup({
    required this.categoryId,
    required this.title,
    this.forums = const [],
  });

  final int categoryId;
  final String title;
  final List<ForumNode> forums;
}

class ForumNodesPage {
  ForumNodesPage({required this.groups});

  final List<ForumNodeGroup> groups;

  factory ForumNodesPage.fromJson(Map<String, dynamic> json) {
    final nodes = <ForumNode>[];
    if (json['nodes'] is List) {
      for (final raw in json['nodes'] as List) {
        if (raw is Map<String, dynamic>) {
          nodes.add(ForumNode.fromJson(raw));
        }
      }
    }

    final byId = {for (final n in nodes) n.nodeId: n};
    final treeMap = json['tree_map'];
    final childIds = <int, List<int>>{};

    if (treeMap is Map) {
      treeMap.forEach((key, value) {
        final parentId = int.tryParse(key.toString()) ?? 0;
        if (value is List) {
          childIds[parentId] = value
              .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
              .where((id) => id > 0)
              .toList();
        }
      });
    }

    List<int> childrenOf(int parentId) => childIds[parentId] ?? [];

    ForumNode withSubForums(ForumNode forum) {
      final subs = childrenOf(forum.nodeId)
          .map((id) => byId[id])
          .whereType<ForumNode>()
          .where((n) => n.isForum)
          .toList()
        ..sort((a, b) {
          final order = a.displayOrder.compareTo(b.displayOrder);
          return order != 0 ? order : a.title.compareTo(b.title);
        });
      return forum.copyWith(subForums: subs);
    }

    final categories = nodes.where((n) => n.isCategory).toList()
      ..sort((a, b) {
        final order = a.displayOrder.compareTo(b.displayOrder);
        return order != 0 ? order : a.nodeId.compareTo(b.nodeId);
      });

    final groups = <ForumNodeGroup>[];
    for (final category in categories) {
      final forums = childrenOf(category.nodeId)
          .map((id) => byId[id])
          .whereType<ForumNode>()
          .where((n) => n.isForum)
          .map(withSubForums)
          .toList()
        ..sort((a, b) {
          final order = a.displayOrder.compareTo(b.displayOrder);
          return order != 0 ? order : a.title.compareTo(b.title);
        });

      if (forums.isNotEmpty) {
        groups.add(ForumNodeGroup(
          categoryId: category.nodeId,
          title: category.title,
          forums: forums,
        ));
      }
    }

    final groupedForumIds = groups
        .expand((g) => g.forums)
        .expand((f) => [f.nodeId, ...f.subForums.map((s) => s.nodeId)])
        .toSet();

    final orphanForums = nodes
        .where((n) => n.isForum && !groupedForumIds.contains(n.nodeId))
        .map(withSubForums)
        .toList();
    if (orphanForums.isNotEmpty) {
      groups.add(ForumNodeGroup(
        categoryId: 0,
        title: 'Forum',
        forums: orphanForums,
      ));
    }

    return ForumNodesPage(groups: groups);
  }
}
