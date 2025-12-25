import 'package:apna_khakra/src/screens/admin/admin_product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/auth_provider.dart';
import '../../state/product_provider.dart';
import '../../state/order_provider.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import '../home_screen.dart';

// Brand Constants
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const AdminProductsScreen(),
    const AdminOrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      orderProvider.fetchOrders();
      productProvider.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: PopScope is the modern replacement for WillPopScope
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: _buildAdminAppBar(context),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: _buildModernNavBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAdminAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kBgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Panel', 
            style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 24)),
          Text('Managing Apna Khakhra', 
            style: GoogleFonts.poppins(color: Colors.black38, fontSize: 12)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            setState(() => _selectedIndex = index);
            // Refresh orders when Orders tab is selected
            if (index == 2) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<OrderProvider>(context, listen: false).refreshOrders();
              });
            }
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kAccentColor,
        unselectedItemColor: Colors.black26,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Store'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, OrderProvider>(
      builder: (context, productProvider, orderProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Performance Overview', 
                style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: Colors.black87)),
              const SizedBox(height: 24),
              
              // Animated Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Total Products',
                      count: productProvider.products.length,
                      icon: Icons.inventory_2_rounded,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatTile(
                      label: 'Active Orders',
                      count: orderProvider.orders.length,
                      icon: Icons.local_mall_rounded,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildQuickActionSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black45)),
        const SizedBox(height: 16),
        _QuickActionRow(
          icon: Icons.add_box_outlined, 
          title: "Add New Product", 
          subtitle: "Launch a new flavor", 
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
            );
          } // Logic for navigation can be added here
        ),
        _QuickActionRow(
          icon: Icons.analytics_outlined, 
          title: "Sales Report", 
          subtitle: "View this month's revenue", 
          onTap: () {}
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.count, required this.icon, required this.color});

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
          Text('$count', 
            style: GoogleFonts.dmSerifDisplay(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          Text(label, 
            style: GoogleFonts.poppins(fontSize: 14, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kBgColor,
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}