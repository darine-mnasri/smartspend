class User {
  final int    id;
  final String nom;
  final String email;

  User({
    required this.id,
    required this.nom,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:    json['id'],
      nom:   json['nom'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id':    id,
    'nom':   nom,
    'email': email,
  };
}