import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/product_provider.dart';
import '../state/cart_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'product_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];

  void _onSearchChanged(String query) {
    final products = Provider.of<ProductProvider>(context, listen: false).products;
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = products.where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const kPrimaryColor = Color(0xFF2D5A27);
    const kBgColor = Color(0xFFFFF9F2);
    const kAccentColor = Color(0xFFFF6B35);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kPrimaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search for crunch...',
              prefixIcon: const Icon(Icons.search, color: kPrimaryColor, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18), 
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    }) 
                : null,
            ),
          ),
        ),
      ),
      body: _searchResults.isEmpty && _searchController.text.isNotEmpty
          ? _buildNoResults()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return _buildSearchTile(product, context, kPrimaryColor, kAccentColor);
              },
            ),
    );
  }

  Widget _buildSearchTile(Product product, BuildContext context, Color primary, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id))),
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product.images.isNotEmpty ? product.images.first : 'https://via.placeholder.com/60',
            width: 60, height: 60, fit: BoxFit.cover,
          ),
        ),
        title: Text(product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('₹${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: accent, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF2D5A27), size: 30),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).addItem(CartItem(product: product, quantity: 1));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No matches found', style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.black45)),
        ],
      ),
    );
  }
} 