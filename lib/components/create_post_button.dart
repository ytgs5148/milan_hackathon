import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/create_post_form.dart';
import 'package:milan_hackathon/utils/auth_service.dart';

class CreatePost extends StatelessWidget {
  const CreatePost({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        final user = await auth.getCurrentUser();

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You need to be logged in to create a post'),
            ),
          );
          return;
        }
              
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return const FractionallySizedBox(
              heightFactor: 0.7,
              child: CreatePostForm(),
            );
          },
        );
      },
    );
  }
}