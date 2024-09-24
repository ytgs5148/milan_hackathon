import 'dart:convert';

import 'package:milan_hackathon/interfaces/post.dart';
import 'package:milan_hackathon/interfaces/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<User> fetchUserData(String emailId) async {
    // final response = await http.get(Uri.parse('https://your-backend-url.com/user/$emailId'));

    // if (response.statusCode == 200) {
    //   return json.decode(response.body);
    // } else {
    //   throw Exception('Failed to load user data');
    // }

    return User(
      name: 'John Doe',
      email: 'johndoe@gmail.com',
      branch: 'CS',
      year: '3',
    );
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('https://your-backend-url.com/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> posts = json.decode(response.body);

      return posts.map<Post>((post) => Post.fromJson(post)).toList();
    } else {
      return [];
    }
  }
}