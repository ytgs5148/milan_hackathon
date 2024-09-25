class Comments {
  final String postId;
  final String authorEmail;
  final String comment;

  Comments({
    required this.postId,
    required this.authorEmail,
    required this.comment,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      postId: json['postId'],
      authorEmail: json['authorEmail'],
      comment: json['comment'],
    );
  }

  static Future<Comments?> fromMap(Map<String, dynamic> commentData) {
    try {
      return Future.value(Comments(
        postId: commentData['postId'],
        authorEmail: commentData['authorEmail'],
        comment: commentData['comment'],
      ));
    } catch (e) {
      return Future.value(null);
    }
  }
}