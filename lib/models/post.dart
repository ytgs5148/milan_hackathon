import 'package:milan_hackathon/models/comments.dart';

class Post {
  final String postId;
  final String title;
  final String description;
  final String authorEmail;
  final int postedAtTimestamp;
  final String imageUrl;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final List<Comments> comments;

  Post({
    required this.postId,
    required this.title,
    required this.description,
    required this.postedAtTimestamp,
    required this.imageUrl,
    required this.comments,
    required this.upvotedBy,
    required this.downvotedBy,
    required this.authorEmail,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      title: json['title'],
      description: json['description'],
      authorEmail: json['authorEmail'],
      postedAtTimestamp: json['postedAtTimestamp'],
      imageUrl: json['imageUrl'],
      upvotedBy: json['upvotedBy'].cast<String>(),
      downvotedBy: json['downvotedBy'].cast<String>(),
      comments: json['comments'].map<Comments>((comment) => Comments.fromJson(comment)).toList(),
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      postedAtTimestamp: map['postedAtTimestamp'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      upvotedBy: (map['upvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      downvotedBy: (map['downvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      authorEmail: map['authorEmail'] ?? '',
      comments: (map['comments'] as List<dynamic>?)
              ?.map((comment) => Comments.fromJson(comment as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}