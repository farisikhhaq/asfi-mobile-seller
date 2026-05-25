import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4, // Data dummy
        itemBuilder: (context, index) {
          final dummyProducts = [
            {'name': 'ASFI Smartwatch Series 9', 'price': 2500000, 'stock': 12, 'sold': 45},
            {'name': 'Kemeja Polos Pria Premium', 'price': 120000, 'stock': 50, 'sold': 120},
            {'name': 'Sepatu Sneakers Kasual', 'price': 450000, 'stock': 8, 'sold': 24},
            {'name': 'Headset Bluetooth TWS', 'price': 299000, 'stock': 0, 'sold': 88},
          ];
          final product = dummyProducts[index];
          final isOutOfStock = product['stock'] == 0;

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
                          product['name'] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(product['price']),
                          style: const TextStyle(color: Color(0xFF43E97B), fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stok: ${product['stock']}',
                              style: TextStyle(
                                color: isOutOfStock ? const Color(0xFFFF6584) : Colors.white70,
                                fontSize: 12,
                                fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Terjual: ${product['sold']}',
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
