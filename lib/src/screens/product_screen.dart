import 'package:apna_khakra/src/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/product_provider.dart';
import '../state/cart_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

// Brand Constants
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class ProductScreen extends StatefulWidget {
  final String productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final product = productProvider.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => throw Exception('Product not found'),
      );
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addToCart() {
    if (_product == null || _product!.stockQuantity == 0) return;
    if (_quantity > _product!.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${_product!.stockQuantity} items available in stock'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(CartItem(product: _product!, quantity: _quantity));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity ${_product!.name} to your bag!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kAccentColor)));

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: kBgColor, elevation: 0),
        body: Center(child: Text(_error ?? 'Product not found', style: GoogleFonts.poppins())),
      );
    }

    return Scaffold(
      backgroundColor: kBgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 32),
                      _buildNutritionHighlights(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomActionTab(),
        ],
      ),
    );
  }

    Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
      ]),
      child: IconButton(icon: Icon(icon, color: Colors.black87, size: 20), onPressed: onTap),
    );
  }

  PreferredSizeWidget _buildTransparentAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                _circleIconButton(Icons.shopping_bag_outlined, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                }),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: kAccentColor, shape: BoxShape.circle),
                      child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        child: PageView.builder(
          itemCount: _product!.images.isEmpty ? 1 : _product!.images.length,
          itemBuilder: (context, index) {
            return Image.network(
              _product!.images.isEmpty ? 'https://via.placeholder.com/400' : _product!.images[index],
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Badge(label: Text("AUTHENTIC"), backgroundColor: kPrimaryColor),
                if (_product!.stockQuantity == 0) ...[
                  const SizedBox(width: 8),
                  const Badge(label: Text("OUT OF STOCK"), backgroundColor: Colors.red),
                ],
              ],
            ),
            Text('₹${_product!.price.toStringAsFixed(0)}', 
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: kAccentColor)),
          ],
        ),
        const SizedBox(height: 12),
        Text(_product!.name, style: GoogleFonts.dmSerifDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('The Crunch Story', style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: kPrimaryColor)),
        const SizedBox(height: 8),
        Text(
          _product!.description.isEmpty ? 'Traditional handmade khakhra roasted to perfection.' : _product!.description,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildNutritionHighlights() {
    final chips = ["🌾 Whole Wheat", "🔥 Hand Roasted", "🚫 No Preservatives"];
    return Wrap(
      spacing: 8,
      children: chips.map((c) => Chip(
        label: Text(c, style: GoogleFonts.poppins(fontSize: 12, color: kPrimaryColor)),
        backgroundColor: kPrimaryColor.withOpacity(0.05),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )).toList(),
    );
  }

  Widget _buildBottomActionTab() {
    final isOutOfStock = _product?.stockQuantity == 0;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: isOutOfStock
              ? SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.grey.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('Out of Stock', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                )
              : Row(
                  children: [
                    // Quantity Toggle
                    Container(
                      decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            icon: const Icon(Icons.remove, size: 18),
                          ),
                          Text('$_quantity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: _product != null && _quantity < _product!.stockQuantity
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Add to Bag Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text('Add to Bag', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}