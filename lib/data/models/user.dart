class User {
  String uid, username, email;

  User({
    required this.uid,
    required this.username,
    required this.email,
  });

  User.fromJson(Map json)
      : uid = json["uid"],
        username = json["username"],
        email = json["email"];
}
