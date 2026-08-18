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
  String? _userEmail;

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

  void _handleLogin(String email, String password) {
    // Di sini Anda bisa menambahkan validasi login ke backend
    // Untuk sekarang, kami hanya simulasi login berhasil
    setState(() {
      _userEmail = email;
      _currentScreen = 2;
    });

    // Tampilkan snackbar sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat datang, $_userEmail!'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      _userEmail = null;
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
      userEmail: _userEmail,
      onLogout: _handleLogout,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String? userEmail;
  final VoidCallback onLogout;

  const MainNavigation({
    Key? key,
    this.userEmail,
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
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
      InventoryScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan platform untuk mendeteksi iOS atau Android
    bool isIOS = Platform.isIOS;

    if (isIOS) {
      // CupertinoTabBar untuk iOS
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
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => _screens[index],
          );
        },
      );
    } else {
      // Material BottomNavigationBar untuk Android
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
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
          ],
        ),
      );
    }
  }
}