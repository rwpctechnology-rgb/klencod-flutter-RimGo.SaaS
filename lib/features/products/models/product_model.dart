class ProductModel {
  final String id;
  final String code; // الباركود أو رقم الصنف
  final String name;
  final double purchasePrice;
  final double salePrice;
  final int stockQty;
  final bool isService; // للخدمات التي لا تحتاج مخزون مثل الصيانة

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockQty,
    this.isService = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'stockQty': stockQty,
      'isService': isService,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      stockQty: json['stockQty'] ?? 0,
      isService: json['isService'] ?? false,
    );
  }
}
