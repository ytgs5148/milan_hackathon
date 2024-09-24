class User {
  final String name;
  final String email;
  final String branch;
  final String year;

  User({required this.name, required this.email, required this.branch, required this.year});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      branch: json['branch'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'branch': branch,
    'year': year,
  };
}