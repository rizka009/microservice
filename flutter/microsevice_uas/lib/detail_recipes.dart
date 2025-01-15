import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    double averageRating = 0;
    // Pastikan ada data rating dan hitung rata-rata
    // if (recipe['ratings'] != null && recipe['ratings'].isNotEmpty) {
    //   double sumRating = 0;
    //   recipe['ratings'].forEach((rating) {
    //     sumRating += rating['rating'];
    //   });
    //   averageRating = sumRating / recipe['ratings'].length;
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['name'],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Published on: ${recipe['article_date']}",
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            Text(
              "Ingredients:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            ...recipe['ingredients'].map<Widget>((ingredient) {
              return Text(
                "- $ingredient",
                style: TextStyle(fontSize: 16.0),
              );
            }).toList(),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
