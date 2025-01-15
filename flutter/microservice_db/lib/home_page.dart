import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengelola JSON
import 'package:http/http.dart' as http;
import 'package:microservice_db/detail_product.dart';
import 'package:microservice_db/add_product.dart'; // Impor halaman tambah produk
import 'package:microservice_db/edit_product.dart'; // Impor halaman edit produk
import 'package:microservice_db/cart_page.dart'; // Impor CartPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      print("Fetching products from the server...");
      final response = await http.get(Uri.parse('http://172.27.32.1:3000/products'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          setState(() {
            products = data['data'];
            isLoading = false;
          });
          print("Successfully fetched ${products.length} products.");

        } else {
          throw Exception("Unexpected response format: $data");
        }
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://172.27.32.1:3000/products/$productId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil dihapus!')),
        );
        fetchProducts(); // Perbarui daftar produk setelah dihapus
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text(
          "Daftar Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );

              if (result == true) {
                fetchProducts();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(child: Text("Tidak ada produk.", style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
              child: ListTile(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Icon(Icons.shopping_cart, color: Colors.white),
                title: Text(
                  product['name'],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Rp ${product['price']}",
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductPage(
                              productId: product['id'],
                              name: product['name'],
                              description: product['description'],
                              price: product['price'],
                            ),
                          ),
                        );

                        if (result == true) {
                          fetchProducts();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Konfirmasi Hapus'),
                              content:
                              Text('Apakah Anda yakin ingin menghapus produk ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteProduct(product['id']);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Hapus'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailProdukPage(productId: product['id']),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
