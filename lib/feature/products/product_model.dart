class ProductModel {
  final int id;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String code;
  final double price;
  final int stock;
  final String description;
  final String image;

  ProductModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.code,
    required this.price,
    required this.stock,
    required this.description,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}