import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  static Db? _db;
  static DbCollection? _productsCollection;

  factory MongoDBService() {
    return _instance;
  }

  MongoDBService._internal();

  // Getter untuk database
  static Db? get db => _db;
  static DbCollection? get productsCollection => _productsCollection;

  /// Connect ke MongoDB
  ///
  /// Connection string format:
  /// mongodb+srv://username:password@cluster.mongodb.net/database_name
  static Future<void> connect(String connectionString) async {
    try {
      _db = await Db.create(connectionString);
      await _db!.open();
      _productsCollection = _db!.collection('products');
      print('✅ MongoDB Connected Successfully');
    } catch (e) {
      print('❌ MongoDB Connection Error: $e');
      rethrow;
    }
  }

  /// Disconnect dari MongoDB
  static Future<void> disconnect() async {
    try {
      if (_db != null) {
        await _db!.close();
        print('✅ MongoDB Disconnected');
      }
    } catch (e) {
      print('❌ MongoDB Disconnect Error: $e');
      rethrow;
    }
  }

  /// Get semua produk
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final products = await _productsCollection!.find().toList();
      return products;
    } catch (e) {
      print('❌ Error fetching products: $e');
      rethrow;
    }
  }

  /// Get produk by ID
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final product =
          await _productsCollection!.findOne(where.id(ObjectId.fromHexString(id)));
      return product;
    } catch (e) {
      print('❌ Error fetching product by id: $e');
      rethrow;
    }
  }

  /// Create produk baru
  static Future<String?> createProduct(Map<String, dynamic> productData) async {
    try {
      final result = await _productsCollection!.insertOne(productData);
      print('✅ Product created with ID: ${result.id}');
      return result.id.toString();
    } catch (e) {
      print('❌ Error creating product: $e');
      rethrow;
    }
  }

  /// Helper: ubah Map jadi ModifierBuilder dengan .set per-field
  /// (versi baru mongo_dart tidak bisa terima Map langsung di modify.set)
  static ModifierBuilder _buildSetModifier(Map<String, dynamic> data) {
    ModifierBuilder modifier = modify;
    data.forEach((key, value) {
      modifier = modifier.set(key, value);
    });
    return modifier;
  }

  /// Update produk
  static Future<bool> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final result = await _productsCollection!.updateOne(
        where.id(ObjectId.fromHexString(id)),
        _buildSetModifier(productData),
      );
      print(
          '✅ Product updated. Matched: ${result.nMatched}, Modified: ${result.nModified}');
      return result.nModified > 0;
    } catch (e) {
      print('❌ Error updating product: $e');
      rethrow;
    }
  }

  /// Delete produk
  static Future<bool> deleteProduct(String id) async {
    try {
      final result = await _productsCollection!.deleteOne(
        where.id(ObjectId.fromHexString(id)),
      );
      print('✅ Product deleted. Deleted count: ${result.nRemoved}');
      return result.nRemoved > 0;
    } catch (e) {
      print('❌ Error deleting product: $e');
      rethrow;
    }
  }

  /// Search produk by name
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final products = await _productsCollection!
          .find(
            where.match('name', query),
          )
          .toList();
      return products;
    } catch (e) {
      print('❌ Error searching products: $e');
      rethrow;
    }
  }

  /// Get produk by status
  static Future<List<Map<String, dynamic>>> getProductsByStatus(
    String status,
  ) async {
    try {
      final products = await _productsCollection!
          .find(
            where.eq('status', status),
          )
          .toList();
      return products;
    } catch (e) {
      print('❌ Error fetching products by status: $e');
      rethrow;
    }
  }

  /// Get total count produk
  static Future<int> getProductCount() async {
    try {
      final count = await _productsCollection!.count();
      return count;
    } catch (e) {
      print('❌ Error counting products: $e');
      rethrow;
    }
  }

  /// Update stock produk
  static Future<bool> updateStock(String id, int newStock) async {
    try {
      final status = newStock > 0 ? 'Aktif' : 'Habis';
      final result = await _productsCollection!.updateOne(
        where.id(ObjectId.fromHexString(id)),
        modify.set('stock', newStock).set('status', status),
      );
      return result.nModified > 0;
    } catch (e) {
      print('❌ Error updating stock: $e');
      rethrow;
    }
  }
}