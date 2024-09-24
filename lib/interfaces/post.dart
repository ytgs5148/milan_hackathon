import 'package:milan_hackathon/interfaces/comments.dart';
import 'package:milan_hackathon/interfaces/user.dart';

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
}