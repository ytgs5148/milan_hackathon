import 'package:milan_hackathon/models/comments.dart';
import 'package:milan_hackathon/models/user.dart';

class Post {
  final String postId;
  final String title;
  final String description;
  final User author;
  final int postedAtTimestamp;
  final String imageUrl;
  final int votes;
  final List<Comments> comments;

  Post({
    required this.postId,
    required this.title,
    required this.description,
    required this.author,
    required this.postedAtTimestamp,
    required this.imageUrl,
    required this.votes,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      title: json['title'],
      description: json['description'],
      author: User.fromJson(json['author']),
      postedAtTimestamp: json['postedAtTimestamp'],
      imageUrl: json['imageUrl'],
      votes: json['votes'],
      comments: json['comments'].map<Comments>((comment) => Comments.fromJson(comment)).toList(),
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      author: User.fromJson(map['author'] ?? {}),
      postedAtTimestamp: map['postedAtTimestamp'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      votes: map['votes'] ?? 0,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((comment) => Comments.fromJson(comment as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}