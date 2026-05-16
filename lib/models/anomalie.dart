class Anomalie {
  final int    transactionId;
  final String description;
  final double montant;
  final String? categorie;
  final String dateTransaction;
  final double moyenne;
  final double seuil;
  final String message;

  Anomalie({
    required this.transactionId,
    required this.description,
    required this.montant,
    this.categorie,
    required this.dateTransaction,
    required this.moyenne,
    required this.seuil,
    required this.message,
  });

  factory Anomalie.fromJson(Map<String, dynamic> json) {
    return Anomalie(
      transactionId:   json['transaction_id'],
      description:     json['description'],
      montant:         double.parse(json['montant'].toString()),
      categorie:       json['categorie'],
      dateTransaction: json['date_transaction'],
      moyenne:         double.parse(json['moyenne'].toString()),
      seuil:           double.parse(json['seuil'].toString()),
      message:         json['message'],
    );
  }
}