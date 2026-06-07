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
  static const groupPosts = 'api/group-posts/';
  static const attachmentsNewKey = 'api/attachments/new-key';

  // Kairete Blog (XenForo REST)
  static const blogEntries = 'api/blog-entries';
  static const blogCategories = 'api/blog-categories';
  static const blogs = 'api/blogs/';

  // XenForo forum
  static const nodes = 'api/nodes';
  static const forums = 'api/forums/';
  static const threads = 'api/threads';
  static const posts = 'api/posts/';
  static const reactions = 'api/reactions/';

  // Kairete Social Groups
  static const socialGroups = 'api/social-groups/';
  static const blogEntryComments = 'api/blog-entry-comments/';
  static const groupComments = 'api/group-comments/';
}
