import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Selamat datang kembali!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang di Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola inventory dan marketplace Anda dengan mudah',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Statistik Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ====== RESPONSIVE GRID (pengganti Wrap dengan width fixed) ======
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // Tentukan jumlah kolom sesuai lebar layar
                int crossAxisCount;
                if (width >= 1000) {
                  crossAxisCount = 4; // desktop
                } else if (width >= 700) {
                  crossAxisCount = 3; // tablet landscape
                } else if (width >= 480) {
                  crossAxisCount = 2; // tablet portrait / mobile besar
                } else {
                  crossAxisCount = 1; // mobile kecil
                }

                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // tinggi card FIXED (bukan rasio) -> gak ada lagi
                    // ruang kosong berlebih, konsisten di semua lebar
                    mainAxisExtent: 88,
                  ),
                  children: const [
                    _StatCard(
                      title: 'Total Produk',
                      value: '150',
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Stok Habis',
                      value: '12',
                      icon: Icons.warning_amber,
                      color: Colors.red,
                    ),
                    _StatCard(
                      title: 'Penjualan Hari Ini',
                      value: '45',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Pesanan Baru',
                      value: '8',
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // width dihapus -> card sekarang mengikuti lebar sel GridView (responsive)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}