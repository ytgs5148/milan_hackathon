import 'package:milan_hackathon/interfaces/user.dart';

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
}