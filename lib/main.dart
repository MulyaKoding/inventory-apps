import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 0 = Landing, 1 = Login, 2 = Dashboard
  int _currentScreen = 0;
  String? _userName;

  void _goToLogin() {
    setState(() {
      _currentScreen = 1;
    });
  }

  void _goToLanding() {
    setState(() {
      _currentScreen = 0;
    });
  }

  void _handleLogin(String userName) {
    setState(() {
      _userName = userName;
      _currentScreen = 2;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang, $userName!'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      _userName = null;
      _currentScreen = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda telah keluar dari aplikasi'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen 0: Landing
    if (_currentScreen == 0) {
      return LandingScreen(
        onLoginPressed: _goToLogin,
      );
    }

    // Screen 1: Login
    if (_currentScreen == 1) {
      return LoginScreen(
        onLoginPressed: _handleLogin,
        onBackPressed: _goToLanding,
      );
    }

    // Screen 2: Dashboard (Main Navigation)
    return MainNavigation(
      userName: _userName,
      onLogout: _handleLogout,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String? userName;
  final VoidCallback onLogout;

  const MainNavigation({
    Key? key,
    this.userName,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        userName: widget.userName,
        onLogout: widget.onLogout,
      ),
      const InventoryScreen(),
      const _FeatureScreen(
        title: 'Master Barang',
        subtitle: 'Kelola katalog produk dan SKU',
        icon: Icons.category_outlined,
        accentColor: Color(0xFF8B5CF6),
      ),
      const _FeatureScreen(
        title: 'Stok',
        subtitle: 'Pantau ketersediaan dan saldo stok',
        icon: Icons.bar_chart_rounded,
        accentColor: Color(0xFF7C3AED),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS;

    if (isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cube_box),
              activeIcon: Icon(CupertinoIcons.cube_box_fill),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.tag_fill),
              activeIcon: Icon(CupertinoIcons.tag_fill),
              label: 'Barang',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar_fill),
              activeIcon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Stok',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => _screens[index],
          );
        },
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Barang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_line_chart),
              activeIcon: Icon(Icons.stacked_line_chart),
              label: 'Stok',
            ),
          ],
        ),
      );
    }
  }
}

class _FeatureScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _FeatureScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur ini masih dalam tahap UI preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _PreviewTile(label: 'Data produk', value: '128 item'),
                  _PreviewTile(label: 'Stok tersedia', value: '89 tersedia'),
                  _PreviewTile(label: 'Perlu restock', value: '12 item'),
                  _PreviewTile(label: 'Transaksi hari ini', value: '24 aktivitas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple.shade600,
            ),
          ),
        ],
      ),
    );
  }
}