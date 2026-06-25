import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/marketplace_model.dart';
import '../services/inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: const Text('Inventory Marketplace'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard Inventory',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola stok produk dan data marketplace Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              FutureBuilder<InventoryStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final stats = snapshot.data!;
                    return GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          label: 'Total Produk',
                          value: stats.totalProducts.toString(),
                          subtext: '+12 bulan lalu',
                        ),
                        _StatCard(
                          label: 'Stok Habis',
                          value: stats.outOfStock.toString(),
                          subtext: 'Perlu restock',
                          color: Colors.red,
                        ),
                        _StatCard(
                          label: 'Nilai Stok',
                          value: _formatCurrency(stats.totalValue),
                          subtext: 'Total aset inventory',
                        ),
                        _StatCard(
                          label: 'Marketplace',
                          value: stats.activeMarketplaces.toString(),
                          subtext: 'Platform aktif',
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 24),

              // Toolbar
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari produk atau SKU...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Semua Status',
                          child: Text('Semua Status'),
                        ),
                        DropdownMenuItem(
                          value: 'Aktif',
                          child: Text('Stok Tersedia'),
                        ),
                        DropdownMenuItem(
                          value: 'Rendah',
                          child: Text('Stok Rendah'),
                        ),
                        DropdownMenuItem(
                          value: 'Habis',
                          child: Text('Stok Habis'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _onStatusFilterChanged(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigasi ke halaman tambah produk
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Tambah Produk akan segera hadir'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
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

                  // Apply filters
                  if (_searchQuery.isNotEmpty) {
                    products = products
                        .where((p) =>
                            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            p.sku.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (_selectedStatus != 'Semua Status') {
                    products = products.where((p) => p.status == _selectedStatus).toList();
                  }

                  // Pagination
                  int totalPages = (products.length / _itemsPerPage).ceil();
                  int startIndex = (_currentPage - 1) * _itemsPerPage;
                  int endIndex = startIndex + _itemsPerPage;
                  List<Product> paginatedProducts = products.sublist(
                    startIndex,
                    endIndex > products.length ? products.length : endIndex,
                  );

                  return Column(
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
                        child: Row(
                          children: const [
                            Expanded(flex: 2, child: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Center(child: Text('Stok', style: TextStyle(fontWeight: FontWeight.bold)))),
                            Expanded(child: Center(child: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold)))),
                            Expanded(flex: 2, child: Center(child: Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)))),
                            Expanded(child: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)))),
                            Expanded(child: Center(child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                        ),
                      ),

                      // Table Rows
                      ...paginatedProducts.map((product) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Kategori: ${product.category}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  product.sku,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    product.stock.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _formatCurrency(product.price),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Wrap(
                                    spacing: 4,
                                    children: product.marketplaces
                                        .map((marketplace) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                marketplace,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[700],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(product.status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getStatusColor(product.status),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        iconSize: 18,
                                        onPressed: () {
                                          // TODO: Edit product
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Edit ${product.name}')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        iconSize: 18,
                                        color: Colors.red,
                                        onPressed: () {
                                          // TODO: Delete product
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Hapus ${product.name}')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Pagination Controls
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${startIndex + 1}-${endIndex > products.length ? products.length : endIndex} dari ${products.length} produk',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _currentPage > 1
                                      ? () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  child: const Text('← Sebelumnya'),
                                ),
                                const SizedBox(width: 8),
                                ...[
                                  for (int i = 1; i <= totalPages && i <= 3; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentPage = i;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _currentPage == i ? Colors.blue : Colors.white,
                                          foregroundColor: _currentPage == i ? Colors.white : Colors.black,
                                          side: BorderSide(
                                            color: _currentPage == i ? Colors.blue : Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text('$i'),
                                      ),
                                    ),
                                ],
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _currentPage < totalPages
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  child: const Text('Selanjutnya →'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtext,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}