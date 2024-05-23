import 'package:flutter/material.dart';
import 'package:tienda3_admin/views/add_product.dart';
import 'package:tienda3_admin/views/productlistview.dart';
import '../model/category.dart';
import '../model/brand.dart';
import 'package:tienda3_admin/views/brandlistview.dart';
import 'package:tienda3_admin/views/categorylistview.dart';
import '../model/user.dart';
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
                      label: const Text('Información'))),
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
                      label: const Text('Administrar'))),
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
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(
                  child: Text("No se pudieron cargar los datos"));
            } else {
              var data = snapshot.data!;
              return Column(
                children: <Widget>[
                  ListTile(
                    subtitle: TextButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.attach_money,
                        size: 30.0,
                        color: Colors.green,
                      ),
                      label: Text('${data['revenue']}€',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30.0, color: Colors.green)),
                    ),
                    title: const Text(
                      'Recaudación',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.0, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
              leading: const Icon(Icons.add),
              title: const Text("Añadir producto"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddProduct()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.change_history),
              title: const Text("Lista de productos"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductListView()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text("Añadir categoria"),
              onTap: () {
                _categoryAlert();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Lista de categorias"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryListView()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text("Añadir marca"),
              onTap: () {
                _brandAlert();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text("Lista de marcas"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BrandListView()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Lista de pedidos"),
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

  Future<Map<String, dynamic>> _loadDashboardData() async {
    int usuarios = (await _userService.getUserCount());
    int categorias = (await _categoryService.getCategoryCount());
    int productos = (await _productService.getProductCount());
    int ventas = await _orderService.getCompletedOrderCount();
    double revenue = await _orderService.getTotalRevenue();
    int pedidos = (await _orderService.getOrderCount());
    int devoluciones = 0; //A rellenar más adelante

    return {
      'usuarios': usuarios,
      'categorias': categorias,
      'productos': productos,
      'ventas': ventas,
      'revenue': revenue,
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
            return null;
          },
          decoration: const InputDecoration(hintText: "Añadir categoria"),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              _categoryService.createCategory(categoryController.text);
              Navigator.pop(context);
            },
            child: const Text('Añadir')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar')),
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
              return 'La marca no puede estar vacía';
            }
            return null;
          },
          decoration: const InputDecoration(hintText: "Añadir marca"),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              _brandService.createBrand(brandController.text);
              Navigator.pop(context);
            },
            child: const Text('Añadir')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar')),
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
