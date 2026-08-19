class Product {
  final String id; // Mongo/Prisma id, used for PUT/DELETE
  final String productId; // e.g. PRD-001
  final String name;
  final String category;
  final String sku;
  final int stock;
  final double price;
  final String status; // "In Stock" | "Low Stock" | "Out of Stock"
  final int sold;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.productId,
    required this.name,
    required this.category,
    required this.sku,
    required this.stock,
    required this.price,
    required this.status,
    required this.sold,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : 0,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? 'In Stock',
      sold: (json['sold'] is num) ? (json['sold'] as num).toInt() : 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'sku': sku,
      'stock': stock,
      'price': price,
      'sold': sold,
    };
  }

  // Label bahasa Indonesia untuk ditampilkan di UI
  String get statusLabel {
    switch (status) {
      case 'In Stock':
        return 'Tersedia';
      case 'Low Stock':
        return 'Rendah';
      case 'Out of Stock':
        return 'Habis';
      default:
        return status;
    }
  }
}
