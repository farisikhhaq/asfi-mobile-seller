import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orders = await ApiService.getOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13132B),
        elevation: 0,
        title: const Text('Kelola Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Diproses'),
            Tab(text: 'Dikirim'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
        : TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_orders.where((o) => o['status'] == 'pending').toList(), 'Menunggu', 'Belum ada pesanan masuk.'),
          _buildOrderList(_orders.where((o) => o['status'] == 'processing').toList(), 'Diproses', 'Belum ada pesanan yang sedang Anda proses.'),
          _buildOrderList(_orders.where((o) => o['status'] == 'shipped').toList(), 'Dikirim', 'Tidak ada paket yang sedang dalam pengiriman.'),
          _buildOrderList(_orders.where((o) => o['status'] == 'completed' || o['status'] == 'cancelled').toList(), 'Selesai', 'Belum ada pesanan selesai.'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String statusLabel, String emptyMessage) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13132B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(order['customer_name'] ?? 'Pembeli', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(order['order_number'] ?? 'Order', style: const TextStyle(color: Color(0xFFFFD93D), fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.white24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Belanja', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Kurir: ${order['courier'] ?? '-'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pendapatan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text(currencyFormatter.format(order['total'] ?? 0), style: const TextStyle(color: Color(0xFF43E97B), fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  if (order['status'] == 'pending')
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hanya tampilan. Butuh API update.')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Terima Pesanan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2, color: Colors.white12, size: 70),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }
}
