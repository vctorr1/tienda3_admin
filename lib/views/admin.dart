import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tienda3_admin/views/add_product.dart';
import 'package:tienda3_admin/views/productlistview.dart';
import '../model/category.dart';
import '../model/brand.dart';
import 'package:tienda3_admin/views/brandlistview.dart';
import 'package:tienda3_admin/views/categorylistview.dart';
import '../model/user.dart';
import '../model/order_model.dart' as local; // Importa el modelo con prefijo
import '../model/order.dart';
import 'package:tienda3_admin/views/orderlistview.dart';
import 'package:tienda3_admin/model/product.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();
  ProductService _productService = ProductService();
  UserService _userService = UserService();
  OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                  child: TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                      ),
                      label: Text('Información'))),
              Expanded(
                  child: TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.sort,
                        color:
                            _selectedPage == Page.manage ? active : notActive,
                      ),
                      label: Text('Administrar'))),
            ],
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        return FutureBuilder(
          future: _loadDashboardData(),
          builder: (context, AsyncSnapshot<Map<String, int>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return Center(child: Text("No se pudieron cargar los datos"));
            } else {
              var data = snapshot.data!;
              return Column(
                children: <Widget>[
                  ListTile(
                    subtitle: TextButton.icon(
                      onPressed: null,
                      icon: Icon(
                        Icons.attach_money,
                        size: 30.0,
                        color: Colors.green,
                      ),
                      label: Text('12,000',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 30.0, color: Colors.green)),
                    ),
                    title: Text(
                      'Recaudación',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      children: <Widget>[
                        _buildDashboardCard("Usuarios", Icons.people_outline,
                            data['usuarios'] ?? 0),
                        _buildDashboardCard("Categorias", Icons.category,
                            data['categorias'] ?? 0),
                        _buildDashboardCard("Productos", Icons.track_changes,
                            data['productos'] ?? 0),
                        _buildDashboardCard(
                            "Ventas", Icons.tag_faces, data['ventas'] ?? 0),
                        _buildDashboardCard("Pedidos", Icons.shopping_cart,
                            data['pedidos'] ?? 0),
                        _buildDashboardCard("Devoluciones", Icons.close,
                            data['devoluciones'] ?? 0),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        );
      case Page.manage:
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Añadir producto"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddProduct()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.change_history),
              title: Text("Lista de productos"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductListView()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("Añadir categoria"),
              onTap: () {
                _categoryAlert();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Lista de categorias"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryListView()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Añadir marca"),
              onTap: () {
                _brandAlert();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text("Lista de marcas"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BrandListView()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Lista de pedidos"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OrderListView()));
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Future<Map<String, int>> _loadDashboardData() async {
    int usuarios = (await _userService.getUserCount()) ?? 0;
    int categorias = (await _categoryService.getCategoryCount()) ?? 0;
    int productos = (await _productService.getProductCount()) ?? 0;
    int ventas = 13; // Aquí puedes agregar lógica para contar las ventas
    int pedidos = (await _orderService.getOrderCount()) ?? 0;
    int devoluciones =
        0; // Aquí puedes agregar lógica para contar las devoluciones

    return {
      'usuarios': usuarios,
      'categorias': categorias,
      'productos': productos,
      'ventas': ventas,
      'pedidos': pedidos,
      'devoluciones': devoluciones
    };
  }

  void _categoryAlert() {
    var alert = AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'La categoría no puede estar vacía';
            }
          },
          decoration: InputDecoration(hintText: "Añadir categoria"),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              if (categoryController.text != null) {
                _categoryService.createCategory(categoryController.text);
              }
//          Fluttertoast.showToast(msg: 'category created');
              Navigator.pop(context);
            },
            child: Text('AÑADIR')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCELAR')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void _brandAlert() {
    var alert = AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'La categoría no puede estar vacía';
            }
          },
          decoration: InputDecoration(hintText: "Añadir marca"),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              if (brandController.text != null) {
                _brandService.createBrand(brandController.text);
              }
//          Fluttertoast.showToast(msg: 'brand added');
              Navigator.pop(context);
            },
            child: Text('AÑADIR')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCELAR')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  Widget _buildDashboardCard(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Card(
        child: ListTile(
          title: TextButton.icon(
            onPressed: null,
            icon: Icon(icon),
            label: Text(title),
          ),
          subtitle: Text(
            '$count',
            textAlign: TextAlign.center,
            style: TextStyle(color: active, fontSize: 60.0),
          ),
        ),
      ),
    );
  }
}
