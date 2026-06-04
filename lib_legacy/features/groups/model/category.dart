class Category {
  bool? canAddGroup;
  bool? canAddSecretGroup;
  bool? canUploadAttachments;
  int? categoryId;
  String? categoryTitle;
  String? description;
  int? displayOrder;
  int? groupCount;
  int? parentCategoryId;
  String? title;

  Category({
    this.canAddGroup,
    this.canAddSecretGroup,
    this.canUploadAttachments,
    this.categoryId,
    this.categoryTitle,
    this.description,
    this.displayOrder,
    this.groupCount,
    this.parentCategoryId,
    this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        canAddGroup: json['can_add_group'] as bool?,
        canAddSecretGroup: json['can_add_secret_group'] as bool?,
        canUploadAttachments: json['can_upload_attachments'] as bool?,
        categoryId: json['category_id'] as int?,
        categoryTitle: json['category_title'] as String?,
        description: json['description'] as String?,
        displayOrder: json['display_order'] as int?,
        groupCount: json['group_count'] as int?,
        parentCategoryId: json['parent_category_id'] as int?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'can_add_group': canAddGroup,
        'can_add_secret_group': canAddSecretGroup,
        'can_upload_attachments': canUploadAttachments,
        'category_id': categoryId,
        'category_title': categoryTitle,
        'description': description,
        'display_order': displayOrder,
        'group_count': groupCount,
        'parent_category_id': parentCategoryId,
      };
}
