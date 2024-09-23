import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final int index;
  final BuildContext context;

  const Post({
    super.key,
    required this.context,
    required this.index,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  int getVoteCount() {
    return 0;
  }

  int updateVoteCount(int amt) {
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(
              child: Text('IITH'),
            ),
            title: Text('Lambda IITH Milan Hackathon'),
            subtitle: Text('2 hours ago'),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('This is a sample post content. It can be an announcement or a user post.'),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: Image.network(
              'https://i.imgur.com/PYmSceZ.png',
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
            )
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
          )
        ],
      ),
    );
  }
}