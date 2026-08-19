import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15+ (API 35+) memaksa mode edge-to-edge dan mengabaikan
  // systemNavigationBarColor manual. Solusinya: aktifkan edge-to-edge
  // dan buat status bar + navigation bar TRANSPARAN, supaya gradient
  // aplikasi yang terlihat tembus di baliknya (bukan warna solid dari OS).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 0 = Landing, 1 = Login, 2 = Dashboard
  int _currentScreen = 0;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _userPhotoUrl;

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

  void _handleLogin({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? userPhotoUrl,
  }) {
    setState(() {
      _userId = userId;
      _userName = userName;
      _userEmail = userEmail;
      _userPhone = userPhone;
      _userPhotoUrl = userPhotoUrl;
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

  // Dipanggil dari ProfileScreen (lewat HomeScreen -> MainNavigation)
  // setelah profil berhasil diupdate. Meng-update state di sini supaya
  // seluruh widget yang menampilkan data user (AppBar, HomeScreen, dll)
  // ikut ter-refresh dengan data terbaru.
  void _handleProfileUpdated({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userPhotoUrl,
  }) {
    setState(() {
      if (userName != null) _userName = userName;
      if (userEmail != null) _userEmail = userEmail;
      if (userPhone != null) _userPhone = userPhone;
      if (userPhotoUrl != null) _userPhotoUrl = userPhotoUrl;
    });
  }

  void _handleLogout() {
    setState(() {
      _userId = null;
      _userName = null;
      _userEmail = null;
      _userPhone = null;
      _userPhotoUrl = null;
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
    if (_currentScreen == 0) {
      return LandingScreen(onLoginPressed: _goToLogin);
    }

    if (_currentScreen == 1) {
      return LoginScreen(
        onLoginPressed: _handleLogin,
        onBackPressed: _goToLanding,
      );
    }

    return MainNavigation(
      userId: _userId,
      userName: _userName,
      userEmail: _userEmail,
      userPhone: _userPhone,
      userPhotoUrl: _userPhotoUrl,
      onLogout: _handleLogout,
      onProfileUpdated: _handleProfileUpdated,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userPhotoUrl;
  final VoidCallback onLogout;
  final void Function({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userPhotoUrl,
  })? onProfileUpdated;

  const MainNavigation({
    super.key,
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userPhotoUrl,
    required this.onLogout,
    this.onProfileUpdated,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Catatan penting: sebelumnya list ini dibangun sekali saja di
  // initState(), jadi ketika data user berubah (mis. setelah edit
  // profil) HomeScreen di dalam list ini tetap memegang data LAMA,
  // karena initState() tidak dipanggil ulang saat parent rebuild.
  // Sekarang dibangun di build() supaya selalu memakai data terbaru
  // dari widget (yang datang dari AuthWrapper).
  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
        userPhotoUrl: widget.userPhotoUrl,
        onLogout: widget.onLogout,
        onProfileUpdated: widget.onProfileUpdated,
      ),
      const InventoryScreen(),
      const _FeatureScreen(
        title: 'Barang',
        subtitle: 'Kelola daftar barang dan kategori',
        icon: Icons.category_rounded,
        accentColor: Color(0xFF0EA5E9),
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
    final screens = _buildScreens();

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
            builder: (context) => screens[index],
          );
        },
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
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
                  colors: [accentColor, accentColor.withValues(alpha: 0.8)],
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
                      color: Colors.white.withValues(alpha: 0.15),
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
                children: const [
                  _PreviewTile(label: 'Data produk', value: '128 item'),
                  _PreviewTile(label: 'Stok tersedia', value: '89 tersedia'),
                  _PreviewTile(label: 'Perlu restock', value: '12 item'),
                  _PreviewTile(
                    label: 'Transaksi hari ini',
                    value: '24 aktivitas',
                  ),
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
