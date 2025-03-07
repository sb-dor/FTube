class User {
  int? id;
  String? googleServerAuthCode;
  String? email;
  String? imageUrl;
  String? name;

  User({this.id, this.googleServerAuthCode, this.email, this.imageUrl, this.name});

  User copyWith() => User(
    id: id,
    googleServerAuthCode: googleServerAuthCode,
    email: email,
    imageUrl: imageUrl,
    name: name,
  );

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'], email: json['email'], imageUrl: json['image_url'], name: json['name']);
}
