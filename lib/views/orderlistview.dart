import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/order.dart';
import 'editorderpage.dart'; // Asegúrate de tener esta importación

class OrderListView extends StatefulWidget {
  @override
  _OrderListViewState createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _orderListFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _orderListFuture = _orderService.getOrders();
  }

  // Método para abrir la página de edición de pedidos
  void _openEditOrderPage(Order order) async {
    final shouldRefreshList = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderPage(
          order: order,
          // Pasa una función de retorno de datos que actualice la lista de pedidos
          onOrderUpdated: (bool updated) {
            if (updated) {
              setState(() {
                _loadOrders(); // Actualiza la lista de pedidos
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pedidos'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orderListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pedidos disponibles'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                double totalPrice = 0;
                order.items.forEach((item) {
                  totalPrice += (item['precio'] ?? 0) / 100;
                });
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ExpansionTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('ID Pedido: ${order.id}'),
                    children: [
                      ListTile(
                        title: Text(
                          'ID Cliente: ${order.customerId}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.items.map((item) {
                            return ListTile(
                              title: Text('ID Producto: ${item['productId']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nombre: ${item['nombre']}'),
                                  Text(
                                    'Precio: ${(item['precio'] ?? 0) / 100}€',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _openEditOrderPage(
                                    order); // Llama al método para abrir la página de edición
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, order.id);
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Total: $totalPrice€',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Estado: ${order.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar Pedido"),
        content: Text("¿Estás seguro de que deseas eliminar este pedido?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Eliminar"),
            onPressed: () {
              _orderService.deleteOrder(orderId).then((_) {
                Navigator.of(context).pop();
                setState(() {
                  _loadOrders(); // Refrescar la lista de pedidos
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
