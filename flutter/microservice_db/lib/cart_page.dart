import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_cart.dart'; // Import halaman DetailCartPage

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];  // Gunakan List<dynamic> untuk menyimpan data JSON
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('http://172.27.32.1:3002/cart'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Memeriksa apakah response memiliki data yang valid
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            cartItems = data['data'];  // Langsung simpan data JSON ke dalam cartItems
            isLoading = false;
          });
        } else {
          throw Exception("Data cart kosong atau format tidak sesuai.");
        }
      } else {
        throw Exception("Gagal memuat data cart. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cart items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menghapus item dengan konfirmasi
  Future<void> removeFromCart(int itemId) async {
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
                Navigator.of(context).pop();  // Menutup dialog jika memilih "Tidak"
              },
              child: Text("Tidak"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();  // Menutup dialog setelah konfirmasi

                try {
                  final response = await http.delete(Uri.parse('http://172.27.32.1:3002/cart/$itemId'));

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item berhasil dihapus')));
                    fetchCartItems();  // Memperbarui daftar cart setelah item dihapus
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus item.')));
                  }
                } catch (e) {
                  print("Error removing item: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus item.')));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang Belanja"),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(child: Text("Keranjang Anda kosong."))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListTile(
              title: Text(item['name']),  // Mengakses name dari data JSON
              subtitle: Text("Total Belanja: Rp ${item['price']}"),  // Mengakses price dari data JSON
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => removeFromCart(item['id']),  // Memanggil removeFromCart dengan item ID
              ),
              onTap: () {
                // Arahkan ke halaman DetailCartPage dengan mengirimkan cartId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailCartPage(cartId: item['id']),  // Pass the cartId
                  ),
                ).then((result) {
                  if (result == true) {
                    fetchCartItems();  // Update cart setelah item dihapus
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}
