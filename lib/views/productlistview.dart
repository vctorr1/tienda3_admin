import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tienda3_admin/model/product.dart'; // Asegúrate de importar tu servicio de producto

class ProductListView extends StatefulWidget {
  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de productos"),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay productos disponibles"));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productData = product.data() as Map<String, dynamic>;
                return ListTile(
                  leading: productData['imagenes'] != null &&
                          productData['imagenes'].isNotEmpty
                      ? Image.network(productData['imagenes'][0],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image),
                  title: Text(productData['nombre']),
                  subtitle: Text(
                      "Marca: ${productData['marca']}\nPrecio: \$${productData['precio']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, product.id);
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

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Producto"),
        content: Text("¿Estás seguro de que deseas eliminar este producto?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Eliminar"),
            onPressed: () {
              _productService.deleteProduct(productId).then((_) {
                Navigator.of(context).pop();
                setState(() {}); // Refrescar la lista de productos
              });
            },
          ),
        ],
      ),
    );
  }
}
