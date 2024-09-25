class User {
  final String name;
  final String email;
  final String branch;
  final String year;
  final String profilePhoto;

  User({required this.name, required this.email, required this.branch, required this.year, required this.profilePhoto});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      branch: json['branch'],
      year: json['year'],
      profilePhoto: json['profilePhoto'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'branch': branch,
    'year': year,
    'profilePhoto': profilePhoto,
  };

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'branch': branch,
      'year': year,
      'profilePhoto': profilePhoto,
    };
  }

  static Future<User?> fromMap(Map<String, dynamic> data) {
    return Future.value(User(
      name: data['name'],
      email: data['email'],
      branch: data['branch'],
      year: data['year'],
      profilePhoto: data['profilePhoto'],
    ));
  }
}