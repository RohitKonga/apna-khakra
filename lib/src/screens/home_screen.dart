import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this to pubspec.yaml
import '../state/product_provider.dart';
import '../state/cart_provider.dart';
import '../state/auth_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'admin/admin_login_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'product_screen.dart';

// --- THEME CONSTANTS ---
const kAccentColor = Color(0xFFFF6B35); // Vibrant Orange/Terracotta
const kPrimaryColor = Color(0xFF2D5A27); // Elegant Sage/Deep Green
const kBgColor = Color(0xFFFFF9F2); // Warm Cream

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Initialize filtered products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      _filteredProducts = provider.products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        _filteredProducts = provider.products;
      } else {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        _filteredProducts = provider.products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildElegantAppBar(context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: kAccentColor));
          
          // Update filtered products when provider products change
          if (_searchQuery.isEmpty) {
            _filteredProducts = provider.products;
          }
          
          return RefreshIndicator(
            color: kAccentColor,
            onRefresh: () => provider.refreshProducts(),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HeroSection()),
                const SliverToBoxAdapter(child: CategoryQuickLinks()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _sectionHeader(
                      _searchQuery.isEmpty ? "Trending Now" : "Search Results",
                      _searchQuery.isEmpty ? "Handpicked for you" : "${_filteredProducts.length} items found",
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: _filteredProducts.isEmpty && _searchQuery.isNotEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => ModernProductCard(
                              product: _filteredProducts[index],
                              index: index,
                            ),
                            childCount: _filteredProducts.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: BrandStorySection()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildElegantAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kBgColor.withOpacity(0.8),
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Apna Khakhra.',
        style: GoogleFonts.dmSerifDisplay(
          color: kPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
actions: [
  // 1. Login/Profile Button Logic
  Consumer<AuthProvider>(
    builder: (context, auth, _) {
      return _circleIconButton(
        auth.isAuthenticated ? Icons.person_outline : Icons.login_rounded, 
        () {
          if (!auth.isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      );
    },
  ),
  
  // 2. SEARCH BUTTON
  _circleIconButton(Icons.search, () {
    _showSearchDialog(context);
  }),
  
  _buildCartButton(context),
  const SizedBox(width: 12),
],
    );
  }

  Widget _sectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: Colors.black87)),
        Text(sub, style: GoogleFonts.poppins(color: Colors.black45, fontSize: 14)),
        const SizedBox(height: 10),
      ],
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

  Widget _buildCartButton(BuildContext context) {
    return Consumer<CartProvider>(
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
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController(text: _searchQuery);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Search Products', style: GoogleFonts.poppins()),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter product name...',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filterProducts('');
                        Navigator.of(dialogContext).pop();
                      },
                    )
                  : null,
            ),
            onSubmitted: (value) {
              _filterProducts(value);
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchController.clear();
                _filterProducts('');
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                _filterProducts(searchController.text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

// --- NEW COMPONENTS ---

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Badge(label: Text("NEW ARRIVAL"), backgroundColor: kAccentColor),
          const SizedBox(height: 16),
          Text(
            "The Art of\nGujarati Crunch.",
            style: GoogleFonts.dmSerifDisplay(fontSize: 42, color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Handcrafted whole-wheat khakhras\nwith organic spices.",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            child: const Text("Explore Flavour Palette", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class ModernProductCard extends StatelessWidget {
  final Product product;
  final int index;
  const ModernProductCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0, end: 1),
      builder: (context, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(offset: Offset(0, 20 * (1 - val)), child: child),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductScreen(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(product.images.isNotEmpty ? product.images.first : 'https://via.placeholder.com/150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15, right: 15,
                      child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: const Icon(Icons.favorite_border, color: Colors.red, size: 20)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product.price}', style: GoogleFonts.poppins(color: kAccentColor, fontWeight: FontWeight.w700)),
                        Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            return InkWell(
                              onTap: () {
                                cart.addItem(CartItem(product: product, quantity: 1));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Icon(Icons.add_circle, color: kPrimaryColor, size: 28),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BrandStorySection extends StatelessWidget {
  const BrandStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4EF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: kPrimaryColor, size: 40),
          const SizedBox(height: 16),
          Text(
            "Our Tradition",
            style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          const Text(
            "Every Khakhra is hand-pressed and slow-roasted on a traditional clay tawa to ensure you get that perfect heirloom taste.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class CategoryQuickLinks extends StatelessWidget {
  const CategoryQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = ["🌶️ Spicy", "🌿 Methi", "🧀 Butter", "🌾 Diet"];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(cats[i], style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}