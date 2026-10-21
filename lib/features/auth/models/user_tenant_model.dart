class UserTenantModel {
  final String userId;
  final String shopId;
  final String shopName;
  final String baseCurrency; // ILS, JOD, USD
  final bool allowNegativeStock;

  UserTenantModel({
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.baseCurrency,
    this.allowNegativeStock = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shopId': shopId,
      'shopName': shopName,
      'baseCurrency': baseCurrency,
      'allowNegativeStock': allowNegativeStock,
    };
  }

  factory UserTenantModel.fromJson(Map<String, dynamic> json) {
    return UserTenantModel(
      userId: json['userId'] ?? '',
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      baseCurrency: json['baseCurrency'] ?? 'ILS',
      allowNegativeStock: json['allowNegativeStock'] ?? false,
    );
  }
}
