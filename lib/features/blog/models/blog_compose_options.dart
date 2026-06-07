class WritableBlog {
  const WritableBlog({
    required this.blogId,
    required this.title,
    this.slug = '',
  });

  final int blogId;
  final String title;
  final String slug;

  factory WritableBlog.fromJson(Map<String, dynamic> json) {
    return WritableBlog(
      blogId: json['blog_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class BlogCategoryOption {
  const BlogCategoryOption({
    required this.categoryId,
    required this.title,
  });

  final int categoryId;
  final String title;

  factory BlogCategoryOption.fromJson(Map<String, dynamic> json) {
    return BlogCategoryOption(
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}
