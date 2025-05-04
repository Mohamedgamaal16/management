class PaymentMethod {
  final String id;
  final String name;
  final String number;
  final String expiryDate;
  final String cardType;
  final String image;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.number,
    required this.expiryDate,
    required this.cardType,
    required this.image,
  });

  // Convert PaymentMethod to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'image': image,
    };
  }

  // Create a PaymentMethod from a JSON map
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      expiryDate: json['expiryDate'],
      cardType: json['cardType'],
      image: json['image'],
    );
  }
}
