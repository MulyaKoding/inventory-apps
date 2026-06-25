import '../models/product_model.dart';
import '../models/marketplace_model.dart';
import 'mongodb_service.dart';

/// Service yang menjembatani UI (InventoryScreen) dengan MongoDBService.
/// Mengubah Map mentah dari MongoDB jadi objek Product/InventoryStats yang tipenya jelas.
class InventoryService {
  /// Ambil semua produk sebagai List<Product>
  Future<List<Product>> getAllProducts() async {
    final rawProducts = await MongoDBService.getAllProducts();
    return rawProducts.map((map) => Product.fromMap(map)).toList();
  }

  /// Ambil statistik untuk kartu dashboard
  Future<InventoryStats> getStats() async {
    final rawProducts = await MongoDBService.getAllProducts();
    final products = rawProducts.map((map) => Product.fromMap(map)).toList();

    final totalProducts = products.length;
    final outOfStock = products.where((p) => p.status == 'Habis').length;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );

    // Hitung jumlah marketplace unik yang dipakai dari seluruh produk
    final marketplaceSet = <String>{};
    for (final p in products) {
      marketplaceSet.addAll(p.marketplaces);
    }

    return InventoryStats(
      totalProducts: totalProducts,
      outOfStock: outOfStock,
      totalValue: totalValue,
      activeMarketplaces: marketplaceSet.length,
    );
  }

  /// Tambah produk baru
  Future<String?> addProduct(Product product) async {
    return await MongoDBService.createProduct(product.toMap());
  }

  /// Update produk
  Future<bool> updateProduct(String id, Product product) async {
    return await MongoDBService.updateProduct(id, product.toMap());
  }

  /// Hapus produk
  Future<bool> deleteProduct(String id) async {
    return await MongoDBService.deleteProduct(id);
  }

  /// Update stok produk
  Future<bool> updateStock(String id, int newStock) async {
    return await MongoDBService.updateStock(id, newStock);
  }
}