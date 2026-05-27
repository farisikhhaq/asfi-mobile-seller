import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_product_screen.dart';

import '../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final products = await ApiService.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
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
        title: const Text('Semua Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _products.isEmpty
          ? const Center(child: Text('Belum ada produk', style: TextStyle(color: Colors.white54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final stock = product['stock'] ?? 0;
          final isOutOfStock = stock <= 0;
          final price = product['price'] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF13132B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk Mock
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                  child: const Icon(Icons.image, color: Colors.white24, size: 40),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']?.toString() ?? 'Produk Tanpa Nama',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(price),
                          style: const TextStyle(color: Color(0xFF43E97B), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stok: $stock',
                              style: TextStyle(
                                color: isOutOfStock ? const Color(0xFFFF6584) : Colors.white70,
                                fontSize: 12,
                                fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Terjual: ${product['total_sold'] ?? 0}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
