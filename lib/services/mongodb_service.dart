import 'dart:developer' as developer;
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
      developer.log('✅ MongoDB Connected Successfully', name: 'MongoDBService');
    } catch (e) {
      developer.log('❌ MongoDB Connection Error: $e', name: 'MongoDBService');
      rethrow;
    }
  }

  /// Disconnect dari MongoDB
  static Future<void> disconnect() async {
    try {
      if (_db != null) {
        await _db!.close();
        developer.log('✅ MongoDB Disconnected', name: 'MongoDBService');
      }
    } catch (e) {
      developer.log('❌ MongoDB Disconnect Error: $e', name: 'MongoDBService');
      rethrow;
    }
  }

  /// Get semua produk
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final products = await _productsCollection!.find().toList();
      return products;
    } catch (e) {
      developer.log('❌ Error fetching products: $e', name: 'MongoDBService');
      rethrow;
    }
  }

  /// Get produk by ID
  static Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final product = await _productsCollection!
          .findOne(where.id(ObjectId.fromHexString(id)));
      return product;
    } catch (e) {
      developer.log('❌ Error fetching product by id: $e',
          name: 'MongoDBService');
      rethrow;
    }
  }

  /// Create produk baru
  static Future<String?> createProduct(Map<String, dynamic> productData) async {
    try {
      final result = await _productsCollection!.insertOne(productData);
      developer.log('✅ Product created with ID: ${result.id}',
          name: 'MongoDBService');
      return result.id.toString();
    } catch (e) {
      developer.log('❌ Error creating product: $e', name: 'MongoDBService');
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
      developer.log(
          '✅ Product updated. Matched: ${result.nMatched}, Modified: ${result.nModified}',
          name: 'MongoDBService');
      return result.nModified > 0;
    } catch (e) {
      developer.log('❌ Error updating product: $e', name: 'MongoDBService');
      rethrow;
    }
  }

  /// Delete produk
  static Future<bool> deleteProduct(String id) async {
    try {
      final result = await _productsCollection!.deleteOne(
        where.id(ObjectId.fromHexString(id)),
      );
      developer.log('✅ Product deleted. Deleted count: ${result.nRemoved}',
          name: 'MongoDBService');
      return result.nRemoved > 0;
    } catch (e) {
      developer.log('❌ Error deleting product: $e', name: 'MongoDBService');
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
      developer.log('❌ Error searching products: $e', name: 'MongoDBService');
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
      developer.log('❌ Error fetching products by status: $e',
          name: 'MongoDBService');
      rethrow;
    }
  }

  /// Get total count produk
  static Future<int> getProductCount() async {
    try {
      final count = await _productsCollection!.count();
      return count;
    } catch (e) {
      developer.log('❌ Error counting products: $e', name: 'MongoDBService');
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
      developer.log('❌ Error updating stock: $e', name: 'MongoDBService');
      rethrow;
    }
  }
}
