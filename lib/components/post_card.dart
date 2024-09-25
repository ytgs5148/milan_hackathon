import 'package:flutter/material.dart';
import 'package:milan_hackathon/models/post.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final int index;
  final BuildContext context;
  final Post post;

  const PostCard({
    super.key,
    required this.context,
    required this.index,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostState();
}

class _PostState extends State<PostCard> {
  int getVoteCount() {
    return widget.post.votes;
  }

  int updateVoteCount(int amt) {
    return widget.post.votes + amt;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(widget.post.author.name),
            ),
            title: Text(widget.post.title),
            subtitle: Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.post.postedAtTimestamp * 1000))), // Example: Using post timestamp
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.post.description),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: Image.network(
              widget.post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Image not available'));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      setState(() {
                        updateVoteCount(1);
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('${getVoteCount()}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        updateVoteCount(-1);
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      // TODO: Show comments
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('AI Summary'),
                            content: const Text('This is an AI-generated summary of the post.'),
                            actions: [
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}