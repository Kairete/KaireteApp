import 'package:flutter_test/flutter_test.dart';
import 'package:kairete/features/forum/services/forum_tenant_groups.dart';

void main() {
  test('groups juve forums under Juventus Forum category via breadcrumbs', () {
    final nodes = [
      {
        'node_id': 6,
        'title': 'Juve Social',
        'node_type_id': 'Forum',
        'parent_node_id': 5,
        'display_order': 1,
        'breadcrumbs': [
          {'node_id': 5, 'title': 'Sports Italia', 'node_type_id': 'Category'},
        ],
      },
      {
        'node_id': 7,
        'title': 'Juventus Forum',
        'node_type_id': 'Category',
        'parent_node_id': 6,
        'display_order': 1,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
        ],
      },
      {
        'node_id': 31,
        'title': 'Assistenza Juve Social',
        'node_type_id': 'Category',
        'parent_node_id': 6,
        'display_order': 20,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
        ],
      },
      {
        'node_id': 8,
        'title': 'Juventus Forum',
        'node_type_id': 'Forum',
        'parent_node_id': 7,
        'display_order': 1,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
          {'node_id': 7, 'title': 'Juventus Forum', 'node_type_id': 'Category'},
        ],
      },
      {
        'node_id': 9,
        'title': 'Juve Live',
        'node_type_id': 'Forum',
        'parent_node_id': 7,
        'display_order': 2,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
          {'node_id': 7, 'title': 'Juventus Forum', 'node_type_id': 'Category'},
        ],
      },
    ];

    final groups = buildTenantForumGroups(
      rawNodes: nodes,
      mappedNodeIds: {6},
    );

    expect(groups.map((g) => g.title), contains('Juventus Forum'));
    expect(groups.map((g) => g.title), contains('Assistenza Juve Social'));
    expect(groups.any((g) => g.title == 'Juve Social'), isFalse);

    final juve = groups.firstWhere((g) => g.title == 'Juventus Forum');
    expect(juve.forums.map((f) => f.title), containsAll(['Juventus Forum', 'Juve Live']));

    final assist = groups.firstWhere((g) => g.title == 'Assistenza Juve Social');
    expect(assist.forums, isEmpty);
  });

  test('groups by breadcrumbs when scope has only leaf forum ids', () {
    final nodes = [
      {
        'node_id': 8,
        'title': 'Juventus Forum',
        'node_type_id': 'Forum',
        'parent_node_id': 7,
        'display_order': 1,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
          {'node_id': 7, 'title': 'Juventus Forum', 'node_type_id': 'Category'},
        ],
      },
      {
        'node_id': 9,
        'title': 'Juve Live',
        'node_type_id': 'Forum',
        'parent_node_id': 7,
        'display_order': 2,
        'breadcrumbs': [
          {'node_id': 6, 'title': 'Juve Social', 'node_type_id': 'Forum'},
          {'node_id': 7, 'title': 'Juventus Forum', 'node_type_id': 'Category'},
        ],
      },
    ];

    final groups = buildTenantForumGroups(
      rawNodes: nodes,
      mappedNodeIds: {8, 9},
    );

    expect(groups, hasLength(1));
    expect(groups.single.title, 'Juventus Forum');
    expect(groups.single.forums, hasLength(2));
  });
}
