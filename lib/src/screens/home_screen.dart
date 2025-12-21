import 'package:apna_khakra/src/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this to pubspec.yaml
import '../state/product_provider.dart';
import '../state/cart_provider.dart';
import '../state/auth_provider.dart';
import '../models/product.dart';

// --- THEME CONSTANTS ---
const kAccentColor = Color(0xFFFF6B35); // Vibrant Orange/Terracotta
const kPrimaryColor = Color(0xFF2D5A27); // Elegant Sage/Deep Green
const kBgColor = Color(0xFFFFF9F2); // Warm Cream

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildElegantAppBar(context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: kAccentColor));
          
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
                    child: _sectionHeader("Trending Now", "Handpicked for you"),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ModernProductCard(product: provider.products[index], index: index),
                      childCount: provider.products.length,
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
  // 1. ADD THIS: Login Button Logic
  Consumer<AuthProvider>(
    builder: (context, auth, _) {
      return _circleIconButton(
        auth.isAuthenticated ? Icons.person_outline : Icons.login_rounded, 
        () {
          if (!auth.isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            // Navigate to profile if already logged in
          }
        },
      );
    },
  ),
  
  // 2. SEARCH BUTTON (Existing)
  _circleIconButton(Icons.search, () {}),
  
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
          _circleIconButton(Icons.shopping_bag_outlined, () {}),
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
                      const Icon(Icons.add_circle, color: kPrimaryColor, size: 28),
                    ],
                  )
                ],
              ),
            )
          ],
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
          const Icon(Icons.call, color: kPrimaryColor, size: 40),
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