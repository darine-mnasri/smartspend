class Budget {
  final int    id;
  final String categorie;
  final double plafond;

  Budget({
    required this.id,
    required this.categorie,
    required this.plafond,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id:        json['id'],
      categorie: json['categorie'],
      plafond:   double.parse(json['plafond'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'categorie': categorie,
    'plafond':   plafond,
  };
}