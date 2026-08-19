import 'package:flutter/material.dart';
import '../models/product_model.dart';
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
      case 'In Stock':
        return Colors.green;
      case 'Low Stock':
        return Colors.amber;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    try {
      await _inventoryService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} berhasil dihapus')),
      );
      setState(_loadData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final categoryController = TextEditingController(text: product.category);
    final skuController = TextEditingController(text: product.sku);
    final stockController =
        TextEditingController(text: product.stock.toString());
    final priceController =
        TextEditingController(text: product.price.toStringAsFixed(0));

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${product.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    if (!mounted) return;

    try {
      await _inventoryService.updateProduct(
        id: product.id,
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        sku: skuController.text.trim(),
        stock: int.tryParse(stockController.text.trim()) ?? product.stock,
        price: double.tryParse(priceController.text.trim()) ?? product.price,
        sold: product.sold,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui')),
      );
      setState(_loadData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
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
                      label: 'Terjual',
                      value: '${stats.totalSold}',
                      icon: Icons.trending_up_rounded,
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
                          value: 'In Stock', child: Text('Stok Tersedia')),
                      DropdownMenuItem(
                          value: 'Low Stock', child: Text('Stok Rendah')),
                      DropdownMenuItem(
                          value: 'Out of Stock', child: Text('Stok Habis')),
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
              const SizedBox(height: 20),

              // Products - Card View
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
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

                  if (products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada produk ditemukan',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  int totalPages = (products.length / _itemsPerPage).ceil();
                  int startIndex = (_currentPage - 1) * _itemsPerPage;
                  int endIndex = startIndex + _itemsPerPage;
                  List<Product> paginatedProducts = products.sublist(
                    startIndex,
                    endIndex > products.length ? products.length : endIndex,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive card grid: 1 column on phones, more on wide screens
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth < 700
                              ? 1
                              : constraints.maxWidth < 1100
                                  ? 2
                                  : 3;

                          if (crossAxisCount == 1) {
                            // Single column: simple list, natural height per card
                            return Column(
                              children: paginatedProducts
                                  .map((product) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _ProductCard(
                                          product: product,
                                          statusColor:
                                              _getStatusColor(product.status),
                                          formatCurrency: _formatCurrency,
                                          onEdit: () => _editProduct(product),
                                          onDelete: () =>
                                              _deleteProduct(product),
                                        ),
                                      ))
                                  .toList(),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: paginatedProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 210,
                            ),
                            itemBuilder: (context, index) {
                              final product = paginatedProducts[index];
                              return _ProductCard(
                                product: product,
                                statusColor: _getStatusColor(product.status),
                                formatCurrency: _formatCurrency,
                                onEdit: () => _editProduct(product),
                                onDelete: () => _deleteProduct(product),
                              );
                            },
                          );
                        },
                      ),

                      // Pagination
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 500;

                          final info = Text(
                            'Menampilkan ${startIndex + 1}-${endIndex > products.length ? products.length : endIndex} dari ${products.length} produk',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          );

                          final controls = Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: const Text('← Sebelumnya'),
                              ),
                              for (int i = 1; i <= totalPages && i <= 3; i++)
                                ElevatedButton(
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
                                    minimumSize: const Size(40, 36),
                                  ),
                                  child: Text('$i'),
                                ),
                              OutlinedButton(
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: const Text('Selanjutnya →'),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                info,
                                const SizedBox(height: 10),
                                controls,
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info,
                              controls,
                            ],
                          );
                        },
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

// ====== Product Card ======
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color statusColor;
  final String Function(double) formatCurrency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.statusColor,
    required this.formatCurrency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name/category + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Info row: SKU, Stok, Harga, Terjual
          Row(
            children: [
              Expanded(
                child: _InfoTile(label: 'SKU', value: product.sku),
              ),
              Expanded(
                child:
                    _InfoTile(label: 'Stok', value: product.stock.toString()),
              ),
              Expanded(
                child: _InfoTile(
                    label: 'Harga', value: formatCurrency(product.price)),
              ),
              Expanded(
                child:
                    _InfoTile(label: 'Terjual', value: product.sold.toString()),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
