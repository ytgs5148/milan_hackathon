import 'package:milan_hackathon/models/user.dart';

class Comments {
  final String postId;
  final User author;
  final String comment;

  Comments({
    required this.postId,
    required this.author,
    required this.comment,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      postId: json['postId'],
      author: User.fromJson(json['author']),
      comment: json['comment'],
    );
  }
}