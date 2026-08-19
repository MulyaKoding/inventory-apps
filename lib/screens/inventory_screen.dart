import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/marketplace_model.dart';
import '../services/inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<Product>> _productsFuture;
  late Future<InventoryStats> _statsFuture;

  String _searchQuery = '';
  String _selectedStatus = 'Semua Status';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _productsFuture = _inventoryService.getAllProducts();
    _statsFuture = _inventoryService.getStats();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return Colors.green;
      case 'Rendah':
        return Colors.amber;
      case 'Habis':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Daftar Produk',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola stok produk dan data marketplace Anda',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // ====== Statistics Cards (compact layout) ======
              FutureBuilder<InventoryStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stats = snapshot.data!;

                  final items = [
                    _CompactInventoryStatCard(
                      label: 'Total Produk',
                      value: '${stats.totalProducts}',
                      icon: Icons.inventory_2_outlined,
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFFF5F3FF),
                    ),
                    _CompactInventoryStatCard(
                      label: 'Stok Habis',
                      value: '${stats.outOfStock}',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      bgColor: const Color(0xFFFFEBEE),
                    ),
                    _CompactInventoryStatCard(
                      label: 'Nilai Stok',
                      value: _formatCurrency(stats.totalValue),
                      icon: Icons.attach_money_rounded,
                      color: const Color(0xFF9B6BFF),
                      bgColor: const Color(0xFFEDE9FE),
                    ),
                    _CompactInventoryStatCard(
                      label: 'Marketplace',
                      value: '${stats.activeMarketplaces}',
                      icon: Icons.storefront_outlined,
                      color: const Color(0xFFC4B5FD),
                      bgColor: const Color(0xFFF5F3FF),
                    ),
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 600
                          ? 2
                          : constraints.maxWidth < 980
                              ? 3
                              : 4;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio:
                            constraints.maxWidth < 600 ? 1.9 : 2.4,
                        children: items,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;

                  final searchField = TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari produk atau SKU...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  );

                  final statusDropdown = DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Semua Status', child: Text('Semua Status')),
                      DropdownMenuItem(
                          value: 'Aktif', child: Text('Stok Tersedia')),
                      DropdownMenuItem(
                          value: 'Rendah', child: Text('Stok Rendah')),
                      DropdownMenuItem(
                          value: 'Habis', child: Text('Stok Habis')),
                    ],
                    onChanged: (value) {
                      if (value != null) _onStatusFilterChanged(value);
                    },
                  );

                  // Di layar sempit, susun vertikal
                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        statusDropdown,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 2, child: searchField),
                      const SizedBox(width: 12),
                      Expanded(child: statusDropdown),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Products Table
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Product> products = snapshot.data ?? [];

                  if (_searchQuery.isNotEmpty) {
                    products = products
                        .where((p) =>
                            p.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            p.sku
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (_selectedStatus != 'Semua Status') {
                    products = products
                        .where((p) => p.status == _selectedStatus)
                        .toList();
                  }

                  int totalPages = (products.length / _itemsPerPage).ceil();
                  int startIndex = (_currentPage - 1) * _itemsPerPage;
                  int endIndex = startIndex + _itemsPerPage;
                  List<Product> paginatedProducts = products.sublist(
                    startIndex,
                    endIndex > products.length ? products.length : endIndex,
                  );

                  // Tabel tetap horizontal-scrollable (tabel dengan banyak
                  // kolom memang butuh scroll di layar sempit — ini wajar
                  // dan sudah best practice, bukan bug)
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Row(
                            children: [
                              SizedBox(
                                  width: 160,
                                  child: Text('Produk',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 90,
                                  child: Text('SKU',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              SizedBox(
                                  width: 60,
                                  child: Center(
                                      child: Text('Stok',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              SizedBox(
                                  width: 80,
                                  child: Center(
                                      child: Text('Harga',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              SizedBox(
                                  width: 160,
                                  child: Center(
                                      child: Text('Marketplace',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              SizedBox(
                                  width: 80,
                                  child: Center(
                                      child: Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                              SizedBox(
                                  width: 80,
                                  child: Center(
                                      child: Text('Aksi',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))),
                            ],
                          ),
                        ),

                        // Table Rows
                        ...paginatedProducts.map((product) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey[300]!)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text('Kategori: ${product.category}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(product.sku,
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: Text(product.stock.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Text(_formatCurrency(product.price)),
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Center(
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: product.marketplaces
                                          .map((m) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(m,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.blue[700])),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(product.status)
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _getStatusColor(product.status),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          iconSize: 18,
                                          onPressed: () => ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Edit ${product.name}'))),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          iconSize: 18,
                                          color: Colors.red,
                                          onPressed: () => ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Hapus ${product.name}'))),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Pagination
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 710,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Menampilkan ${startIndex + 1}-${endIndex > products.length ? products.length : endIndex} dari ${products.length} produk',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      side:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    child: const Text('← Sebelumnya'),
                                  ),
                                  const SizedBox(width: 8),
                                  for (int i = 1;
                                      i <= totalPages && i <= 3;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            setState(() => _currentPage = i),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _currentPage == i
                                              ? Colors.blue
                                              : Colors.white,
                                          foregroundColor: _currentPage == i
                                              ? Colors.white
                                              : Colors.black,
                                          side: BorderSide(
                                              color: _currentPage == i
                                                  ? Colors.blue
                                                  : Colors.grey[300]!),
                                        ),
                                        child: Text('$i'),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _currentPage < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      side:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    child: const Text('Selanjutnya →'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Inventory Stat Card Widget
class _CompactInventoryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _CompactInventoryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
