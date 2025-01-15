import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'edit_cart.dart';

class DetailCartPage extends StatefulWidget {
  final int cartId;

  DetailCartPage({super.key, required this.cartId});

  @override
  _DetailCartPageState createState() => _DetailCartPageState();
}

class _DetailCartPageState extends State<DetailCartPage> {
  Map<String, dynamic> cartItem = {};  // Menyimpan item cart yang diterima
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartDetail();
  }

  // Fungsi untuk mengambil detail item cart berdasarkan cartId
  Future<void> fetchCartDetail() async {
    try {
      final response = await http.get(Uri.parse('http://172.27.32.1:3002/cart/${widget.cartId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            cartItem = data['data'];  // Menyimpan data item cart yang diterima
            isLoading = false;
          });
        } else {
          throw Exception("Data detail cart tidak ditemukan.");
        }
      } else {
        throw Exception("Gagal memuat detail cart. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cart detail: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menghapus item dari cart
  Future<void> removeFromCart() async {
    // Menampilkan dialog konfirmasi penghapusan
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Penghapusan"),
          content: Text("Apakah Anda yakin ingin menghapus item ini dari keranjang?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Tutup dialog jika memilih "Tidak"
              },
              child: Text("Tidak"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();  // Tutup dialog

                try {
                  final response = await http.delete(
                    Uri.parse('http://172.27.32.1:3002/cart/${cartItem['id']}'),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item berhasil dihapus')));
                    Navigator.pop(context, true);  // Kembali ke halaman cart dan beri tahu bahwa item dihapus
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus item')));
                  }
                } catch (e) {
                  print("Error removing item: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus item')));
                }
              },
              child: Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data harga produk dan jumlah produk
    final int price = int.tryParse(cartItem['price'].toString()) ?? 0;  // Pastikan harga menjadi int
    final int quantity = int.tryParse(cartItem['quantity'].toString()) ?? 0;  // Pastikan quantity menjadi int

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Cart"),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItem.isEmpty
          ? Center(child: Text("Detail cart tidak ditemukan."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan Nama Produk
            Text(
              "Nama Produk: ${cartItem['name'] ?? 'Nama produk tidak tersedia'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            // Menampilkan Jumlah Produk
            Text(
              "Jumlah: ${cartItem['quantity'] ?? 0}",  // Menampilkan jumlah produk
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            // Menampilkan Total Belanja
            Text(
              "Total Belanja: Rp ${cartItem['price'] ?? 0}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            // Tombol untuk mengedit quantity
            ElevatedButton(
              onPressed: () async {
                // Menavigasi ke halaman EditCartPage dan menunggu hasilnya
                final updatedQuantity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCartPage(
                      cartId: cartItem['id'],
                      currentQuantity: cartItem['quantity'],

                    ),
                  ),
                );

                // Cek apakah data berhasil diperbarui
                if (updatedQuantity != null) {
                  setState(() {
                    // Perbarui quantity yang baru
                    cartItem['quantity'] = updatedQuantity;
                  });
                }
              },
              child: Text("Edit Quantity"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
              ),
            ),
            SizedBox(height: 16.0),
            // Tombol untuk menghapus item
            ElevatedButton(
              onPressed: removeFromCart,
              child: Text("Hapus dari Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
