import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tienda3_admin/model/category.dart'; // Asegúrate de importar tu servicio de categoría

class CategoryListView extends StatefulWidget {
  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de categorías"),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay categorías disponibles"));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryData = category.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.category),
                  title: Text(categoryData['categoria']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, category.id);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Categoría"),
        content: Text("¿Estás seguro de que deseas eliminar esta categoría?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Eliminar"),
            onPressed: () {
              _categoryService.deleteCategory(categoryId).then((_) {
                Navigator.of(context).pop();
                setState(() {}); // Refrescar la lista de categorías
              });
            },
          ),
        ],
      ),
    );
  }
}
