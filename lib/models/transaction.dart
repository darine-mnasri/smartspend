class Transaction {
  final int     id;
  final String  description;
  final double  montant;
  final String? categorie;
  final String  dateTransaction;
  final String? createdAt;

  Transaction({
    required this.id,
    required this.description,
    required this.montant,
    this.categorie,
    required this.dateTransaction,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id:              json['id'],
      description:     json['description'],
      // MySQL retourne montant en String → on parse en double
      montant:         double.parse(json['montant'].toString()),
      categorie:       json['categorie'],
      dateTransaction: json['date_transaction'],
      createdAt:       json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'description':      description,
    'montant':          montant,
    'date_transaction': dateTransaction,
  };
}