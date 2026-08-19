import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class InventoryStats {
  final int totalProducts;
  final int outOfStock;
  final double totalValue;
  final int totalSold;

  InventoryStats({
    required this.totalProducts,
    required this.outOfStock,
    required this.totalValue,
    required this.totalSold,
  });
}

class InventoryService {
  static const String baseUrl = 'https://inventory-usr.vercel.app/api/products';

  // GET semua produk
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data produk (${response.statusCode})');
    }
  }

  // Stats dihitung sendiri di client karena API belum punya endpoint stats
  Future<InventoryStats> getStats() async {
    final products = await getAllProducts();

    final totalProducts = products.length;
    final outOfStock = products.where((p) => p.status == 'Out of Stock').length;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final totalSold = products.fold<int>(0, (sum, p) => sum + p.sold);

    return InventoryStats(
      totalProducts: totalProducts,
      outOfStock: outOfStock,
      totalValue: totalValue,
      totalSold: totalSold,
    );
  }

  // POST tambah produk baru
  Future<Product> createProduct({
    required String name,
    required String category,
    required String sku,
    required int stock,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'category': category,
        'sku': sku,
        'stock': stock,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Gagal menambah produk');
    }
  }

  // PUT update produk by id
  Future<Product> updateProduct({
    required String id,
    required String name,
    required String category,
    required String sku,
    required int stock,
    required double price,
    required int sold,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'category': category,
        'sku': sku,
        'stock': stock,
        'price': price,
        'sold': sold,
      }),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Gagal update produk');
    }
  }

  // DELETE produk by id
  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Gagal menghapus produk');
    }
  }
}
