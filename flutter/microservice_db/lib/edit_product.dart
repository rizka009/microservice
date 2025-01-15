import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProductPage extends StatefulWidget {
  final int productId;
  final String name;
  final String description;
  final int price;

  EditProductPage({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price.toString());
  }

  Future<void> updateProduct() async {
    try {
      final response = await http.put(
        Uri.parse('http://172.27.32.1:3000/products/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': int.parse(_priceController.text),
        }),
      );

      if (response.statusCode == 200) {
        // Menampilkan pesan sukses dengan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil diperbarui!')),
        );

        // Kembali ke halaman sebelumnya setelah berhasil
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Produk"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nama Produk",
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Deskripsi",
              ),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number, // Pastikan ini berada di sini
              decoration: InputDecoration(
                labelText: "Harga",
                hintText: "Masukkan harga produk",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,
              child: Text("Perbarui Produk"),
            ),
          ],
        ),
      ),
    );
  }
}
