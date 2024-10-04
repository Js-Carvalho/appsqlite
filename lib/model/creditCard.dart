class CreditCard {
  int? id;
  String? cardHolderName;
  String? cardNumber;
  String? cvv;
  String? expiryDate;

  CreditCard({
    this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.cvv,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? null,
      'cardHolderName': cardHolderName!,
      'cardNumber': cardNumber!,
      'cvv': cvv!,
      'expiryDate': expiryDate!,
    };
  }

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      cardHolderName: map['cardHolderName'],
      cardNumber: map['cardNumber'],
      cvv: map['cvv'],
      expiryDate: map['expiryDate'],
    );
  }
}
