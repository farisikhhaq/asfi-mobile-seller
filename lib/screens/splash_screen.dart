import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Tahan splash screen selama 2 detik agar animasinya terlihat premium
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image dari gambar pengguna
          Image.asset(
            'assets/images/splash_seller.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Jika gambar belum disalin, gunakan warna fallback gradient bernuansa teal/emerald
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'ASFI SELLER',
                    style: TextStyle(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          
          // Loading Indicator
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43E97B)), // Warna emerald/teal yang serasi
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat ASFI Seller Center...',
                  style: TextStyle(
                    color: const Color(0xFF43E97B).withOpacity(0.8),
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
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
