part of __projectName__.domain;

/// Entity representing blog post.
class Post {
  /// The ID of this post.
  final int id;

  /// The title of this post.
  String title;

  /// The contents of this post.
  String body;

  /// The date when this post was created.
  DateTime createdAt;

  Post(this.id, this.title, this.body, this.createdAt);
}
