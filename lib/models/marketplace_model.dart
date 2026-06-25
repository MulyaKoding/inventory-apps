class Marketplace {
  final String id;
  final String name;
  final bool isActive;

  Marketplace({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory Marketplace.fromMap(Map<String, dynamic> map) {
    return Marketplace(
      id: map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isActive': isActive,
    };
  }
}

/// Statistik ringkas untuk dashboard inventory
class InventoryStats {
  final int totalProducts;
  final int outOfStock;
  final double totalValue;
  final int activeMarketplaces;

  InventoryStats({
    required this.totalProducts,
    required this.outOfStock,
    required this.totalValue,
    required this.activeMarketplaces,
  });
}