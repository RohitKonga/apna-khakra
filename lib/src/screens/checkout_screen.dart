import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/cart_provider.dart';
import '../state/auth_provider.dart';
import '../state/user_order_provider.dart';
import '../state/product_provider.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'admin/admin_login_screen.dart';
import 'product_screen.dart';

// Brand Palette
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);
const double kMinimumOrderValue = 149.0;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        _nameController.text = authProvider.name ?? '';
        _emailController.text = authProvider.email ?? '';
        _phoneController.text = authProvider.phone ?? '';
        _addressController.text = authProvider.address ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Logic remains exactly as provided ---
  Future<void> _submitOrder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in before placing an order.'))
        );
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
      }
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.totalAmount < kMinimumOrderValue) {
      if (mounted) {
        final difference = kMinimumOrderValue - cartProvider.totalAmount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Minimum order value is ₹${kMinimumOrderValue.toStringAsFixed(0)}. Add ₹${difference.toStringAsFixed(0)} more.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final order = Order(
        id: '',
        customerName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        items: cartProvider.items.map((item) {
          final orderItemMap = item.toOrderItem();
          return OrderItem(
            productId: orderItemMap['productId'] as String,
            name: orderItemMap['name'] as String,
            price: orderItemMap['price'] as double,
            qty: orderItemMap['qty'] as int,
          );
        }).toList(),
        total: cartProvider.totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ApiService.createOrder(order);
      
      if (authProvider.isAuthenticated && !authProvider.isAdmin) {
        await authProvider.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
        final userOrderProvider = Provider.of<UserOrderProvider>(context, listen: false);
        await userOrderProvider.refreshUserOrders();
      }
      
      cartProvider.clear();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! 🎉'),
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
        title: Text('Checkout', style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 24)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) return const Center(child: Text('Your cart is empty'));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionHeader("Shipping Details", Icons.local_shipping_outlined),
                  const SizedBox(height: 16),
                  
                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(_nameController, "Full Name", Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildTextField(_emailController, "Email", Icons.alternate_email, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildTextField(_addressController, "Delivery Address", Icons.map_outlined, maxLines: 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader("Order Summary", Icons.receipt_long_outlined),
                  const SizedBox(height: 16),
                  
                  _buildSummaryCard(cart),
                  
                  if (cart.totalAmount < kMinimumOrderValue) ...[
                    const SizedBox(height: 16),
                    _buildMinimumOrderWarning(cart),
                    const SizedBox(height: 16),
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        final difference = kMinimumOrderValue - cart.totalAmount;
                        final suggestions = _getProductSuggestions(
                          productProvider.products,
                          cart.items.map((item) => item.product.id).toList(),
                          difference,
                        );
                        if (suggestions.isNotEmpty) {
                          return _buildProductSuggestions(suggestions);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  // Final Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Confirm & Place Order', 
                              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kAccentColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: kPrimaryColor)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: kPrimaryColor),
        labelStyle: TextStyle(color: Colors.black38),
        filled: true,
        fillColor: kBgColor.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart) {
    final isBelowMinimum = cart.totalAmount < kMinimumOrderValue;
    final difference = kMinimumOrderValue - cart.totalAmount;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBelowMinimum 
              ? [Colors.orange.withOpacity(0.9), Colors.orange]
              : [kPrimaryColor.withOpacity(0.9), kPrimaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: (isBelowMinimum ? Colors.orange : kPrimaryColor).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: GoogleFonts.poppins(color: Colors.white70)),
              Text("₹${cart.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery", style: GoogleFonts.poppins(color: Colors.white70)),
              Text("FREE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          if (isBelowMinimum) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Minimum Order", style: GoogleFonts.poppins(color: Colors.white70)),
                Text("₹${kMinimumOrderValue.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add more",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "₹${difference.toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("₹${cart.totalAmount.toStringAsFixed(0)}", 
                style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 26,fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumOrderWarning(CartProvider cart) {
    final difference = kMinimumOrderValue - cart.totalAmount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Minimum order value is ₹${kMinimumOrderValue.toStringAsFixed(0)}. Add ₹${difference.toStringAsFixed(0)} more to place order.',
              style: GoogleFonts.poppins(
                color: Colors.orange.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _getProductSuggestions(
    List<Product> allProducts,
    List<String> cartProductIds,
    double targetAmount,
  ) {
    // Filter out products already in cart and out of stock
    final availableProducts = allProducts.where((p) =>
      !cartProductIds.contains(p.id) &&
      p.stockQuantity > 0 &&
      p.price <= targetAmount + 50 // Products within reasonable range
    ).toList();
    
    // Sort by price closest to target amount
    availableProducts.sort((a, b) {
      final diffA = (a.price - targetAmount).abs();
      final diffB = (b.price - targetAmount).abs();
      return diffA.compareTo(diffB);
    });
    
    // Return top 3 suggestions
    return availableProducts.take(3).toList();
  }

  Widget _buildProductSuggestions(List<Product> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Products',
          style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: kPrimaryColor),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final product = suggestions[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id)),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.images.isNotEmpty ? product.images.first : 'https://via.placeholder.com/60',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kAccentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            return IconButton(
                              icon: const Icon(Icons.add_circle, color: kPrimaryColor, size: 24),
                              onPressed: () {
                                cart.addItem(CartItem(product: product, quantity: 1));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}