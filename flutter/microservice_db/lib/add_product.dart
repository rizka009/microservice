import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      print("Mengirim data ke server...");
      final response = await http.post(
        Uri.parse('http://172.27.32.1:3000/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "name": _nameController.text,
          "description": _descriptionController.text,
          "price": int.parse(_priceController.text),
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseBody = jsonDecode(response.body);

      // Memeriksa berdasarkan statusCode dan field "success"
      if (response.statusCode == 201 || responseBody['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk: ${response.body}')),
        );
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addProduct,
                child: Text('Tambah Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
