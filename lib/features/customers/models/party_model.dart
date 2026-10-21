class PartyModel {
  final String id;
  final String name;
  final String phone;
  final String type; // 'customer' أو 'supplier'
  final double balance; // موجب يعني له، سالب يعني عليه (ديون)

  PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'balance': balance,
    };
  }

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      type: json['type'] ?? 'customer',
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }
}
