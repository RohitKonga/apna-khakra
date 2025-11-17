import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/order_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? const Center(child: Text('No orders'))
              : RefreshIndicator(
                  onRefresh: () => orderProvider.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text('Order #${order.id.substring(0, 8)}'),
                          subtitle: Text(
                            '${order.customerName} • ₹${order.total.toStringAsFixed(0)}',
                          ),
                          trailing: Chip(
                            label: Text(order.status.toUpperCase()),
                            backgroundColor: _getStatusColor(order.status),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer: ${order.customerName}'),
                                  Text('Email: ${order.email}'),
                                  Text('Phone: ${order.phone}'),
                                  Text('Address: ${order.address}'),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const Text('Items:',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  ...order.items.map((item) => Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${item.name} x${item.qty} - ₹${item.price.toStringAsFixed(0)}',
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ₹${order.total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: order.status,
                                    decoration: const InputDecoration(
                                      labelText: 'Update Status',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text('Pending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'processing',
                                        child: Text('Processing'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'shipped',
                                        child: Text('Shipped'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'delivered',
                                        child: Text('Delivered'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'cancelled',
                                        child: Text('Cancelled'),
                                      ),
                                    ],
                                    onChanged: (newStatus) async {
                                      if (newStatus != null) {
                                        await orderProvider.updateOrderStatus(
                                          order.id,
                                          newStatus,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Status updated'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

