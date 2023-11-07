class BlogCateModel {
  bool? canAddBlogEntry;
  bool? canUploadAttachments;
  int? categoryId;
  String? description;
  int? displayOrder;
  int? parentCategoryId;
  String? title;

  BlogCateModel({
    this.canAddBlogEntry,
    this.canUploadAttachments,
    this.categoryId,
    this.description,
    this.displayOrder,
    this.parentCategoryId,
    this.title,
  });

  factory BlogCateModel.fromJson(Map<String, dynamic> json) => BlogCateModel(
        canAddBlogEntry: json['can_add_blog_entry'] as bool?,
        canUploadAttachments: json['can_upload_attachments'] as bool?,
        categoryId: json['category_id'] as int?,
        description: json['description'] as String?,
        displayOrder: json['display_order'] as int?,
        parentCategoryId: json['parent_category_id'] as int?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'can_add_blog_entry': canAddBlogEntry,
        'can_upload_attachments': canUploadAttachments,
        'category_id': categoryId,
        'description': description,
        'display_order': displayOrder,
        'parent_category_id': parentCategoryId,
        'title': title,
      };
}
