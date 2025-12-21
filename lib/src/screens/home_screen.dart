import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/product_provider.dart';
import '../state/cart_provider.dart';
import '../state/auth_provider.dart';
import '../models/product.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.brown.shade100,
        title: const Text(
          'Apna Khakhra',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.isAdmin)
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        color: Colors.brown,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen(),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, _) => Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart, color: Colors.brown),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Login', style: TextStyle(color: Colors.brown)),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final products = provider.products;
          return RefreshIndicator(
            onRefresh: () => provider.refreshProducts(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AnimatedHeroSection(),
                  const SizedBox(height: 12),
                  const AnimatedHighlightsSection(),
                  if (products.isNotEmpty)
                    AnimatedBestSellerSection(products: products),
                  const AnimatedAboutSection(),
                  const AnimatedReviewsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🎬 Animated Hero Section
class AnimatedHeroSection extends StatelessWidget {
  const AnimatedHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff3e5ab), Color(0xfff5deb3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentic Gujarati Khakhra',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Freshly roasted with love – Taste the crunch of tradition.',
              style: TextStyle(fontSize: 16, color: Colors.brown),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  onPressed: () {},
                  child: const Text('Shop Now'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.brown.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: const Text('View Combos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌟 Animated Highlights
class AnimatedHighlightsSection extends StatelessWidget {
  const AnimatedHighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final highlights = [
      ('🔥 Freshly Roasted', 'Traditional slow-roast process'),
      ('🌾 Pure Ingredients', '100% whole wheat, no preservatives'),
      ('💛 Authentic Taste', 'Home-style Gujarati flavours'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: highlights.map((item) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade100.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.$2, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 🛍️ Best Seller Grid with Animation
class AnimatedBestSellerSection extends StatelessWidget {
  final List<Product> products;
  const AnimatedBestSellerSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Best Sellers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(scale: value, child: child),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductScreen(productId: product.id),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product.images.isNotEmpty
                                  ? product.images.first
                                  : 'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('₹${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 💬 About + Reviews with Parallax Feel
class AnimatedAboutSection extends StatelessWidget {
  const AnimatedAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Why Apna Khakhra?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            'Apna Khakhra brings you traditional Gujarati snacks with authentic recipes and honest ingredients, roasted to perfection for that delightful crunch.',
          ),
        ],
      ),
    );
  }
}

class AnimatedReviewsSection extends StatelessWidget {
  const AnimatedReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      '⭐⭐⭐⭐⭐ “Best khakhra, super crunchy!” – Samir',
      '⭐⭐⭐⭐⭐ “Tastes exactly like homemade.” – Vaishali',
      '⭐⭐⭐⭐⭐ “Very fresh & light!” – Kunal',
    ];

    return Container(
      color: Colors.brown.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What Our Customers Say',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 600),
                child: Text(review, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
