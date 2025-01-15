import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditCartPage extends StatefulWidget {
  final int cartId;
  final int currentQuantity;

  EditCartPage({super.key, required this.cartId, required this.currentQuantity});

  @override
  _EditCartPageState createState() => _EditCartPageState();
}

class _EditCartPageState extends State<EditCartPage> {
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.currentQuantity.toString();
  }

  // Fungsi untuk memperbarui quantity
  Future<void> updateCartQuantity() async {
    try {
      final int updatedQuantity = int.tryParse(_quantityController.text) ?? widget.currentQuantity;

      if (updatedQuantity <= 0) {
        // Validasi: pastikan quantity lebih dari 0
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jumlah tidak valid')));
        return;
      }

      final response = await http.put(
        Uri.parse('http://172.27.32.1:3002/cart/${widget.cartId}'),
        body: json.encode({
          'quantity': updatedQuantity,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jumlah berhasil diperbarui')));
        Navigator.pop(context, updatedQuantity);  // Kembali dengan nilai quantity yang baru
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui jumlah')));
      }
    } catch (e) {
      print("Error updating cart quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui jumlah')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Quantity"),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jumlah Produk:"),
            SizedBox(height: 8.0),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Masukkan jumlah baru",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateCartQuantity,
              child: Text("Perbarui Quantity"),
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
