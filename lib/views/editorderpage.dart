import 'package:flutter/material.dart';
import '../model/order.dart';
import '../model/order_model.dart';

class EditOrderPage extends StatefulWidget {
  final Order order;
  final Function(bool) onOrderUpdated; // Función de retorno de datos

  EditOrderPage({required this.order, required this.onOrderUpdated});

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final OrderService _orderService = OrderService();
  late Order _editedOrder;

  @override
  void initState() {
    super.initState();
    _editedOrder = widget.order;
  }

  void _removeProduct(int index) {
    setState(() {
      _editedOrder = _orderService.removeProduct(_editedOrder, index);
    });
  }

  void _changeStatus(String newStatus) {
    setState(() {
      _editedOrder = _orderService.changeOrderStatus(_editedOrder, newStatus);
    });
  }

  void _saveOrder() {
    _orderService.updateOrder(_editedOrder).then((_) {
      // Llama a la función de retorno de datos y pasa true para indicar que se actualizó el pedido
      widget.onOrderUpdated(true);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pedido'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('ID Pedido: ${_editedOrder.id}'),
          ),
          ListTile(
            title: Text('ID Cliente: ${_editedOrder.customerId}'),
          ),
          ListTile(
            title: Text('Estado del Pedido'),
            subtitle: DropdownButton<String>(
              value: _editedOrder.status,
              onChanged: (String? newStatus) {
                if (newStatus != null) {
                  _changeStatus(newStatus);
                }
              },
              items: <String>[
                'Pendiente',
                'En preparación',
                'Enviado',
                'Completado'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Productos'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _editedOrder.items.map((item) {
                return ListTile(
                  title: Text('ID Producto: ${item['productId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${item['nombre']}'),
                      Text('Precio: ${(item['precio'] ?? 0) / 100}€'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeProduct(_editedOrder.items.indexOf(item));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
