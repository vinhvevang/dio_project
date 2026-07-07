import 'package:dio_complete/data/models/category_model.dart';

class Product {
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

  /// Backend trả danh mục dưới dạng OBJECT LỒNG "category": {...} (không phải
  /// field phẳng "category_id") - xác nhận từ dữ liệu thật lấy về từ GET
  /// /products. Nullable vì sản phẩm có thể chưa được gán danh mục.
  final Category? category;

  /// Tiện dùng để so sánh/lọc mà không cần null-check category? mỗi lần.
  int? get categoryId => category?.id;

  Product({
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
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
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
      category: json['category'] is Map
          ? Category.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
    );
  }

  /// Lưu ý: khi GHI (create/update), backend nhận "category_id" (số) chứ
  /// không phải object "category" lồng như lúc ĐỌC - xem product_service.dart.
  /// toJson() này hiện không được service dùng trực tiếp (create/update tự
  /// dựng map riêng để tách rõ 2 chiều đọc/ghi), giữ lại cho mục đích chung.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'price': price,
      'stock': stock,
      'description': description,
      'image': image,
      if (category != null) 'category_id': category!.id,
    };
  }

  Product copyWith({
    int? id,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? name,
    String? code,
    double? price,
    int? stock,
    String? description,
    String? image,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }
}
