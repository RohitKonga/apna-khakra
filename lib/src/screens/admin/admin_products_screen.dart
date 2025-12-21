import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/product_provider.dart';
import 'admin_product_form_screen.dart';

// Brand Palette
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: kBgColor,
      // Floating Action Button Styled for the Theme
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Product", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : productProvider.products.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: () => productProvider.refreshProducts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Extra bottom padding for FAB
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return _AdminProductTile(product: product, provider: productProvider);
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
          Icon(Icons.inventory_2_outlined, size: 80, color: kPrimaryColor.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('No products found', style: GoogleFonts.dmSerifDisplay(fontSize: 22, color: kPrimaryColor)),
        ],
      ),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  final dynamic product;
  final ProductProvider provider;

  const _AdminProductTile({required this.product, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          // Product Image Preview
          Hero(
            tag: product.id,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kBgColor,
                borderRadius: BorderRadius.circular(18),
                image: product.images.isNotEmpty
                    ? DecorationImage(image: NetworkImage(product.images.first), fit: BoxFit.cover)
                    : null,
              ),
              child: product.images.isEmpty ? const Icon(Icons.image, color: Colors.black12) : null,
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(color: kAccentColor, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              _circleActionBtn(Icons.edit_outlined, kPrimaryColor, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product)),
                );
              }),
              const SizedBox(width: 8),
              _circleActionBtn(Icons.delete_outline_rounded, Colors.redAccent, () async {
                final confirm = await _showDeleteDialog(context);
                if (confirm == true) {
                  await provider.deleteProduct(product.id);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: kBgColor,
        title: Text('Delete Product?', style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor)),
        content: Text('This action cannot be undone. Are you sure?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.black38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}