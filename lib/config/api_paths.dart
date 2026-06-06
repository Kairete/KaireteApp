class ApiPaths {
  ApiPaths._();

  static const auth = 'api/auth';
  static const users = 'api/users';
  static const me = 'api/me';

  // OmniFeed / newsfeed (XenForo add-on API)
  static const newsfeed = 'api/newsfeed';
  static const newsfeedItems = 'api/newsfeed-items/';
  static const newsfeedComments = 'api/newsfeed-items/';
  static const newsfeedCommentReplies = 'api/newsfeed-comments/';
  static const profilePosts = 'api/profile-posts';
  static const attachmentsNewKey = 'api/attachments/new-key';

  // Kairete Blog (XenForo REST)
  static const blogEntries = 'api/blog-entries';
  static const blogCategories = 'api/blog-categories';
  static const blogs = 'api/blogs/';
}
