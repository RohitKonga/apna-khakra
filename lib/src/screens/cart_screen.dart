import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/cart_provider.dart';
import 'checkout_screen.dart';

// Brand Constants
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
        title: Text('Your Bag', style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 24)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(item: item, cart: cart);
                  },
                ),
              ),
              _buildCheckoutSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: kPrimaryColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('Your bag is empty', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: kPrimaryColor)),
          const SizedBox(height: 8),
          Text('Looks like you haven\'t added any crunch yet.', style: GoogleFonts.poppins(color: Colors.black38)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Start Shopping', style: TextStyle(color: kAccentColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: GoogleFonts.poppins(color: Colors.black45, fontWeight: FontWeight.w500)),
                Text('₹${cart.totalAmount.toStringAsFixed(0)}', 
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text('Proceed to Checkout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final CartProvider cart;

  const _CartItemTile({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: kBgColor,
              width: 80,
              height: 80,
              child: item.product.images.isNotEmpty
                  ? Image.network(item.product.images.first, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: Colors.black12),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('₹${item.product.price.toStringAsFixed(0)}', 
                  style: GoogleFonts.poppins(color: kAccentColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Quantity Selector
                Row(
                  children: [
                    _quantityBtn(Icons.remove, () {
                      if (item.quantity > 1) {
                        cart.updateQuantity(item.product.id, item.quantity - 1);
                      } else {
                        cart.removeItem(item.product.id);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                    _quantityBtn(Icons.add, () => cart.updateQuantity(item.product.id, item.quantity + 1)),
                  ],
                )
              ],
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            onPressed: () => cart.removeItem(item.product.id),
          ),
        ],
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kPrimaryColor),
      ),
    );
  }
}