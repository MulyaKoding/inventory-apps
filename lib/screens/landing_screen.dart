import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const LandingScreen({
    super.key,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAF5FF), // ungu hampir putih
              Color(0xFFEDE4FF), // ungu pastel
              Color(0xFFD8C4F7), // ungu lembut
              Color(0xFFBBA3EE), // ungu soft
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo/Icon Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9B6BFF),
                          Color(0xFF7C3AED),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF9B6BFF).withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const _InvBrandLogo(),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Inventa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C1D95),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'Kelola stok produk dan\nmarketplace Anda dengan mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B4B9E),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Feature List
                  const _FeatureItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard Lengkap',
                    description: 'Pantau semua statistik penjualan Anda',
                  ),
                  const SizedBox(height: 20),
                  const _FeatureItem(
                    icon: Icons.inventory_outlined,
                    title: 'Manajemen Inventory',
                    description: 'Kontrol stok produk dengan akurat',
                  ),
                  const SizedBox(height: 20),
                  const _FeatureItem(
                    icon: Icons.sync_outlined,
                    title: 'Multi Marketplace',
                    description: 'Sinkronisasi dengan berbagai platform',
                  ),

                  const SizedBox(height: 60),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor:
                            const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Masuk ke Aplikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Text
                  const Text(
                    'Masukkan email dan password Anda untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C6491),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvBrandLogo extends StatelessWidget {
  const _InvBrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'INV',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF5F3FF),
                Color(0xFFEDE9FE),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8B5CF6),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
