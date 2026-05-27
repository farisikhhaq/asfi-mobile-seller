import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'products_screen.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'orders_screen.dart';
import '../services/prayer_time_service.dart';
import 'payment_methods_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_currentIndex == 0) {
      bodyContent = const _HomeContent();
    } else if (_currentIndex == 1) {
      bodyContent = const ProductsScreen();
    } else if (_currentIndex == 2) {
      bodyContent = const OrdersScreen();
    } else {
      bodyContent = const _DummyPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A), // Mengikuti tema gelap ASFI Web
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF13132B),
        selectedItemColor: const Color(0xFF6C63FF), // ASFI Primary
        unselectedItemColor: Colors.white30,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String _selectedOrderTab = 'Menunggu';
  PrayerData? _prayerData;
  Timer? _countdownTimer;
  String _countdownText = '';
  String _storeName = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadPrayerData();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _storeName = prefs.getString('store_name') ?? 'Toko Official ASFI';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    final data = await PrayerTimeService.getPrayerData();
    if (data != null && mounted) {
      setState(() {
        _prayerData = data;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdownText();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCountdownText();
        });
      }
    });
  }

  void _updateCountdownText() {
    if (_prayerData == null) return;
    
    final diff = _prayerData!.targetTime.difference(DateTime.now());
    
    if (diff.isNegative) {
      _loadPrayerData(); // Update jadwal otomatis jika waktu sudah lewat
      return;
    }

    int hours = diff.inHours;
    int minutes = diff.inMinutes.remainder(60);
    int seconds = diff.inSeconds.remainder(60);
    
    if (hours > 0) {
      _countdownText = '$hours jam $minutes mnt $seconds dtk lagi';
    } else if (minutes > 0) {
      _countdownText = '$minutes mnt $seconds dtk lagi';
    } else {
      _countdownText = '$seconds dtk lagi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Wallet Card Area
          SizedBox(
            height: 270, 
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Header (ASFI & Nama Tenant)
                Container(
                  height: 240, // Ditinggikan agar lengkungannya di bawah kartu
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 45, left: 24, right: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1E36), Color(0xFF13132B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ASFI Seller Center',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _storeName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_prayerData != null) ...[
                                  const SizedBox(width: 8),
                                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on, color: Colors.white54, size: 12),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _prayerData!.locationName,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Waktu Sholat Real-Time
                            if (_prayerData != null)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF43E97B).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.mosque, color: Color(0xFF43E97B), size: 12),
                                          const SizedBox(width: 6),
                                          Text('${_prayerData!.nextPrayerName} ${_prayerData!.nextPrayerTimeStr}', style: const TextStyle(color: Color(0xFF43E97B), fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(_countdownText, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              )
                          else
                            Row(
                              children: const [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF43E97B)),
                                ),
                                SizedBox(width: 8),
                                Text('Mendeteksi Lokasi...', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                        ],
                      ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        tooltip: 'Keluar Akun',
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // The ASFI-style Card
                Positioned(
                  top: 150, // Diturunkan secara presisi agar tidak menutupi waktu sholat
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFFF6584)], // Gradient tema web
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          // Prominent Left Button (like "Pay/Tarik")
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fungsi Tarik Dana')));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                                  SizedBox(height: 4),
                                  Text('Tarik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          // Right Side content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Top row: Logo and Balance
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.store, color: Colors.white, size: 12),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('Pendapatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                        ],
                                      ),
                                      const Text('Rp 4.500.000', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                  // Bottom row: Actions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _SmallWalletAction(icon: Icons.add_box, label: 'Tambah', onTap: () {}),
                                      _SmallWalletAction(icon: Icons.credit_card, label: 'Rekening', onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                                      }),
                                      _SmallWalletAction(icon: Icons.open_in_new, label: 'Kunjungi', onTap: () {}),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Menu Grid - Disesuaikan dengan fitur WEB

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _MenuIcon(
                  icon: Icons.inventory_2, 
                  label: 'Semua Produk', 
                  color: const Color(0xFF6C63FF), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
                  }
                ),
                _MenuIcon(
                  icon: Icons.add_box, 
                  label: 'Tambah Produk', 
                  color: const Color(0xFF43E97B), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                  }
                ),
                _MenuIcon(
                  icon: Icons.receipt_long, 
                  label: 'Pesanan', 
                  color: const Color(0xFFFF6584), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                  }
                ),
                _MenuIcon(icon: Icons.local_shipping, label: 'Pengiriman', color: const Color(0xFFFFD93D), onTap: () {}),
                _MenuIcon(icon: Icons.account_balance, label: 'Metode Bayar', color: const Color(0xFF6C63FF), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                }),
                _MenuIcon(
                  icon: Icons.bar_chart, 
                  label: 'Statistik', 
                  color: const Color(0xFF43E97B), 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                  }
                ),
                _MenuIcon(icon: Icons.store, label: 'Info Toko', color: const Color(0xFFFF6584), onTap: () {}),
                _MenuIcon(icon: Icons.grid_view, label: 'Lainnya', color: Colors.grey, onTap: () {}),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Top Picks Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Pesanan Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          
          // Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildChip('Menunggu', _selectedOrderTab == 'Menunggu', () => setState(() => _selectedOrderTab = 'Menunggu')),
                _buildChip('Diproses', _selectedOrderTab == 'Diproses', () => setState(() => _selectedOrderTab = 'Diproses')),
                _buildChip('Dikirim', _selectedOrderTab == 'Dikirim', () => setState(() => _selectedOrderTab = 'Dikirim')),
                _buildChip('Selesai', _selectedOrderTab == 'Selesai', () => setState(() => _selectedOrderTab = 'Selesai')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pesanan Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildOrderContent(),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOrderContent() {
    if (_selectedOrderTab == 'Menunggu') {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13132B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ada 2 pesanan menunggu!', style: TextStyle(color: Color(0xFFFFD93D), fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Segera konfirmasi agar pembeli senang.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF13132B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            const Icon(Icons.inbox, color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text('Tidak ada pesanan yang ${_selectedOrderTab.toLowerCase()}.', style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      );
    }
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF13132B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SmallWalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallWalletAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuIcon({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), // Efek transparan ala dark mode
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 24), // Ikon dengan warna solid
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DummyPage extends StatelessWidget {
  const _DummyPage();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D1A),
      body: Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white))),
    );
  }
}
