class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int stock;
  final double price;
  final String status; // 'Aktif', 'Rendah', 'Habis'
  final List<String> marketplaces;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.price,
    required this.status,
    required this.marketplaces,
  });

  /// Buat Product dari dokumen MongoDB (Map)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      category: map['category'] ?? '',
      stock: (map['stock'] ?? 0) is int
          ? map['stock']
          : int.tryParse(map['stock'].toString()) ?? 0,
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price'].toString()) ?? 0.0,
      status: map['status'] ?? 'Aktif',
      marketplaces: map['marketplaces'] != null
          ? List<String>.from(map['marketplaces'])
          : <String>[],
    );
  }

  /// Ubah Product jadi Map untuk disimpan ke MongoDB
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'stock': stock,
      'price': price,
      'status': status,
      'marketplaces': marketplaces,
    };
  }

  /// Hitung status otomatis berdasarkan stok
  static String statusFromStock(int stock) {
    if (stock <= 0) return 'Habis';
    if (stock <= 5) return 'Rendah';
    return 'Aktif';
  }
}