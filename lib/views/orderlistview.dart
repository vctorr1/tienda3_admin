import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/order.dart';

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
                return ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('ID Pedido: ${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente ID: ${order.customerId}'),
                      Text('Items: ${order.items.join(', ')}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navega a la página de edición del pedido si es necesario
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => EditOrderPage(order: order)));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, order.id);
                        },
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
