import '../models/product_model.dart';
import '../models/marketplace_model.dart';

class InventoryService {
  // Dummy data produk
  final List<Product> _dummyProducts = [
    Product(
      id: '1',
      name: 'Kaos Polos Putih',
      sku: 'KPP-001',
      category: 'Pakaian',
      stock: 150,
      price: 75000,
      status: 'Aktif',
      marketplaces: ['Tokopedia', 'Shopee'],
    ),
    Product(
      id: '2',
      name: 'Celana Jeans Slim',
      sku: 'CJS-002',
      category: 'Pakaian',
      stock: 3,
      price: 250000,
      status: 'Rendah',
      marketplaces: ['Shopee'],
    ),
    Product(
      id: '3',
      name: 'Sepatu Sneakers',
      sku: 'SS-003',
      category: 'Sepatu',
      stock: 0,
      price: 450000,
      status: 'Habis',
      marketplaces: ['Tokopedia', 'Lazada'],
    ),
    Product(
      id: '4',
      name: 'Tas Ransel Canvas',
      sku: 'TRC-004',
      category: 'Tas',
      stock: 45,
      price: 180000,
      status: 'Aktif',
      marketplaces: ['Tokopedia', 'Shopee', 'Lazada'],
    ),
    Product(
      id: '5',
      name: 'Jaket Hoodie',
      sku: 'JH-005',
      category: 'Pakaian',
      stock: 0,
      price: 320000,
      status: 'Habis',
      marketplaces: ['Shopee'],
    ),
    Product(
      id: '6',
      name: 'Topi Baseball',
      sku: 'TB-006',
      category: 'Aksesoris',
      stock: 80,
      price: 95000,
      status: 'Aktif',
      marketplaces: ['Tokopedia'],
    ),
    Product(
      id: '7',
      name: 'Kemeja Flannel',
      sku: 'KF-007',
      category: 'Pakaian',
      stock: 2,
      price: 195000,
      status: 'Rendah',
      marketplaces: ['Shopee', 'Lazada'],
    ),
    Product(
      id: '8',
      name: 'Sandal Kulit',
      sku: 'SK-008',
      category: 'Sepatu',
      stock: 60,
      price: 135000,
      status: 'Aktif',
      marketplaces: ['Tokopedia', 'Shopee'],
    ),
    Product(
      id: '9',
      name: 'Dompet Kulit',
      sku: 'DK-009',
      category: 'Aksesoris',
      stock: 25,
      price: 210000,
      status: 'Aktif',
      marketplaces: ['Lazada'],
    ),
    Product(
      id: '10',
      name: 'Ikat Pinggang',
      sku: 'IP-010',
      category: 'Aksesoris',
      stock: 4,
      price: 85000,
      status: 'Rendah',
      marketplaces: ['Tokopedia', 'Shopee'],
    ),
    Product(
      id: '11',
      name: 'Kacamata Hitam',
      sku: 'KH-011',
      category: 'Aksesoris',
      stock: 35,
      price: 120000,
      status: 'Aktif',
      marketplaces: ['Shopee'],
    ),
    Product(
      id: '12',
      name: 'Sweater Rajut',
      sku: 'SR-012',
      category: 'Pakaian',
      stock: 0,
      price: 275000,
      status: 'Habis',
      marketplaces: ['Tokopedia', 'Lazada'],
    ),
  ];

  Future<List<Product>> getAllProducts() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts;
  }

  Future<InventoryStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final totalProducts = _dummyProducts.length;
    final outOfStock =
        _dummyProducts.where((p) => p.status == 'Habis').length;
    final totalValue = _dummyProducts.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );

    final marketplaceSet = <String>{};
    for (final p in _dummyProducts) {
      marketplaceSet.addAll(p.marketplaces);
    }

    return InventoryStats(
      totalProducts: totalProducts,
      outOfStock: outOfStock,
      totalValue: totalValue,
      activeMarketplaces: marketplaceSet.length,
    );
  }

  Future<String?> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dummyProducts.add(product);
    return product.id;
  }

  Future<bool> updateProduct(String id, Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _dummyProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _dummyProducts[index] = product;
      return true;
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _dummyProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _dummyProducts.removeAt(index);
      return true;
    }
    return false;
  }

  Future<bool> updateStock(String id, int newStock) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _dummyProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final p = _dummyProducts[index];
      _dummyProducts[index] = Product(
        id: p.id,
        name: p.name,
        sku: p.sku,
        category: p.category,
        stock: newStock,
        price: p.price,
        status: Product.statusFromStock(newStock),
        marketplaces: p.marketplaces,
      );
      return true;
    }
    return false;
  }
}