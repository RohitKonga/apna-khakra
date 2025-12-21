import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/order_provider.dart';

// Brand Palette consistent with your other screens
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: kBgColor,
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : orderProvider.orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: () => orderProvider.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return _OrderExpansionCard(order: order, provider: orderProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: kPrimaryColor.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('No orders yet', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: kPrimaryColor)),
        ],
      ),
    );
  }
}

class _OrderExpansionCard extends StatelessWidget {
  final dynamic order;
  final OrderProvider provider;

  const _OrderExpansionCard({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            'Order #${order.id.substring(0, 8).toUpperCase()}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            '${order.customerName} • ₹${order.total.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
          ),
          trailing: _StatusBadge(status: order.status),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Customer Info Section
                  _buildInfoRow(Icons.person_outline, "Customer", order.customerName),
                  _buildInfoRow(Icons.email_outlined, "Email", order.email),
                  _buildInfoRow(Icons.phone_android_outlined, "Phone", order.phone),
                  _buildInfoRow(Icons.map_outlined, "Address", order.address),
                  
                  const SizedBox(height: 20),
                  Text("Items Ordered", style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: kPrimaryColor)),
                  const SizedBox(height: 8),
                  
                  // Order Items List
                  ...order.items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: kBgColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item.name} x${item.qty}", style: GoogleFonts.poppins(fontSize: 14)),
                        Text("₹${item.price.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),

                  const SizedBox(height: 20),
                  
                  // Status Update Dropdown
                  Text("Update Status", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black38)),
                  const SizedBox(height: 8),
                  _buildStatusDropdown(context),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Received: ${DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt)}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black26),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: kAccentColor),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: order.status,
          isExpanded: true,
          items: statuses.map((String status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (newStatus) async {
            if (newStatus != null) {
              await provider.updateOrderStatus(order.id, newStatus);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status Updated Successfully'), behavior: SnackBarBehavior.floating),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'processing': color = Colors.blue; break;
      case 'shipped': color = Colors.purple; break;
      case 'delivered': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}