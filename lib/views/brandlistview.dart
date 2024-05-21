import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tienda3_admin/model/brand.dart'; // Asegúrate de importar tu servicio de marca

class BrandListView extends StatefulWidget {
  @override
  _BrandListViewState createState() => _BrandListViewState();
}

class _BrandListViewState extends State<BrandListView> {
  final BrandService _brandService = BrandService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de marcas"),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _brandService.getBrands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay marcas disponibles"));
          } else {
            final brands = snapshot.data!;
            return ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final brandData = brand.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text(brandData['marca']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, brand.id);
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

  void _showDeleteConfirmationDialog(BuildContext context, String brandId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Marca"),
        content: Text("¿Estás seguro de que deseas eliminar esta marca?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Eliminar"),
            onPressed: () {
              _brandService.deleteBrand(brandId).then((_) {
                Navigator.of(context).pop();
                setState(() {}); // Refrescar la lista de marcas
              });
            },
          ),
        ],
      ),
    );
  }
}
