import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set tanggal otomatis saat halaman dibuka
    _dateController.text = DateTime.now().toIso8601String().split('T')[0]; // Format YYYY-MM-DD
  }

  Future<void> addRecipe() async {
    const String url = "http://localhost:3002/recipes";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "article_date": _dateController.text,
          "ingredients": _ingredientsController.text.split(','),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Recipe added successfully!")),
        );
        Navigator.pop(context, true);  // Mengirimkan 'true' ke HomePage
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${errorData['message']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Recipe"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Recipe Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a date";
                  }
                  return null;
                },
                enabled: false, // Menonaktifkan input untuk tanggal
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: "Ingredients (comma-separated)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter ingredients";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addRecipe();
                  }
                },
                child: Text("Add Recipe"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
