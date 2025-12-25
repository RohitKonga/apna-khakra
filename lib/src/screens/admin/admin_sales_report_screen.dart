import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../state/order_provider.dart';
import '../../state/product_provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';

// Brand Palette
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class AdminSalesReportScreen extends StatelessWidget {
  const AdminSalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kPrimaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sales Report',
          style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 24),
        ),
      ),
      body: Consumer2<OrderProvider, ProductProvider>(
        builder: (context, orderProvider, productProvider, _) {
          if (orderProvider.isLoading || productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: kAccentColor));
          }

          final salesData = _calculateSalesData(orderProvider.orders, productProvider.products);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Overview',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Revenue',
                        value: '₹${salesData['totalRevenue'].toStringAsFixed(0)}',
                        icon: Icons.attach_money_rounded,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'Total Profit',
                        value: '₹${salesData['totalProfit'].toStringAsFixed(0)}',
                        icon: Icons.trending_up_rounded,
                        color: kAccentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Orders',
                        value: '${salesData['totalOrders']}',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'Avg Order Value',
                        value: '₹${salesData['avgOrderValue'].toStringAsFixed(0)}',
                        icon: Icons.shopping_cart_rounded,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Text(
                  'Order Details',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                
                if (orderProvider.orders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...orderProvider.orders.map((order) => _OrderProfitCard(
                    order: order,
                    products: productProvider.products,
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _calculateSalesData(List<Order> orders, List<Product> products) {
    double totalRevenue = 0;
    double totalProfit = 0;
    
    for (var order in orders) {
      totalRevenue += order.total;
      
      for (var item in order.items) {
        final product = products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(
            id: '',
            name: item.name,
            slug: '',
            description: '',
            price: item.price,
            actualPrice: 0,
            marginPrice: 0,
            stockQuantity: 0,
            images: [],
            createdAt: DateTime.now(),
          ),
        );
        totalProfit += product.marginPrice * item.qty;
      }
    }
    
    final avgOrderValue = orders.isEmpty ? 0.0 : totalRevenue / orders.length;
    
    return {
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalOrders': orders.length,
      'avgOrderValue': avgOrderValue,
    };
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProfitCard extends StatelessWidget {
  final Order order;
  final List<Product> products;

  const _OrderProfitCard({
    required this.order,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    double orderProfit = 0;
    
    for (var item in order.items) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: '',
          name: item.name,
          slug: '',
          description: '',
          price: item.price,
          actualPrice: 0,
          marginPrice: 0,
          stockQuantity: 0,
          images: [],
          createdAt: DateTime.now(),
        ),
      );
      orderProfit += product.marginPrice * item.qty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Total',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Your Profit',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${orderProfit.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

