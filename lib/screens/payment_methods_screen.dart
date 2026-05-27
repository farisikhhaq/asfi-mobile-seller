import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<dynamic> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    final methods = await ApiService.getPaymentMethods();
    if (mounted) {
      setState(() {
        _paymentMethods = methods;
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
        title: const Text('Metode Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _paymentMethods.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada metode bayar yang diatur.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final type = method['type']?.toString().toUpperCase() ?? 'UNKNOWN';
                    final isActive = method['is_enabled'] == 1 || method['is_enabled'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13132B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type == 'MIDTRANS' ? Icons.payment : Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isActive ? 'Aktif' : 'Tidak Aktif',
                                  style: TextStyle(
                                    color: isActive ? const Color(0xFF43E97B) : const Color(0xFFFF6584),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (val) {
                              // TBD: API to toggle status
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur ubah status belum tersedia di API.')),
                              );
                            },
                            activeColor: const Color(0xFF43E97B),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
