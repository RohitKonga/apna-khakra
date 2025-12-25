import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/product_provider.dart';
import '../../models/product.dart';

// Brand Palette consistent with your other screens
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _actualPriceController = TextEditingController();
  final _marginPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _imagesController = TextEditingController();
  bool _isSubmitting = false;
  
  // Calculated price display
  double _calculatedPrice = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _slugController.text = widget.product!.slug;
      _descriptionController.text = widget.product!.description;
      _actualPriceController.text = widget.product!.actualPrice.toStringAsFixed(0);
      _marginPriceController.text = widget.product!.marginPrice.toStringAsFixed(0);
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _imagesController.text = widget.product!.images.join(', ');
      _calculatedPrice = widget.product!.price;
    }
    
    // Add listeners to calculate price automatically
    _actualPriceController.addListener(_calculatePrice);
    _marginPriceController.addListener(_calculatePrice);
  }
  
  void _calculatePrice() {
    final actualPrice = double.tryParse(_actualPriceController.text.trim()) ?? 0;
    final marginPrice = double.tryParse(_marginPriceController.text.trim()) ?? 0;
    setState(() {
      _calculatedPrice = actualPrice + marginPrice;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _actualPriceController.removeListener(_calculatePrice);
    _marginPriceController.removeListener(_calculatePrice);
    _actualPriceController.dispose();
    _marginPriceController.dispose();
    _stockQuantityController.dispose();
    _imagesController.dispose();
    super.dispose();
  }

  // --- Logic remains exactly as you provided ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final images = _imagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final actualPrice = _actualPriceController.text.trim().isNotEmpty 
          ? double.parse(_actualPriceController.text.trim()) 
          : 0;
      final marginPrice = _marginPriceController.text.trim().isNotEmpty 
          ? double.parse(_marginPriceController.text.trim()) 
          : 0;
      final calculatedPrice = actualPrice + marginPrice;

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim(),
        price: calculatedPrice, // Price is calculated from actualPrice + marginPrice
        actualPrice: actualPrice,
        marginPrice: marginPrice,
        stockQuantity: _stockQuantityController.text.trim().isNotEmpty 
            ? int.parse(_stockQuantityController.text.trim()) 
            : 0,
        images: images,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final success = widget.product == null
          ? await productProvider.createProduct(product)
          : await productProvider.updateProduct(product.id, product);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Product created ✨' : 'Product updated ✅'),
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
        title: Text(
          widget.product == null ? 'Add New Product' : 'Edit Details',
          style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Product Essentials",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38),
              ),
              const SizedBox(height: 16),
              
              _buildModernField(
                controller: _nameController,
                label: "Product Name",
                icon: Icons.fastfood_outlined,
                hint: "e.g. Masala Khakhra",
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              
              _buildModernField(
                controller: _slugController,
                label: "URL Slug",
                icon: Icons.link_rounded,
                hint: "e.g. masala-khakhra",
                validator: (v) => (v == null || v.isEmpty) ? 'Slug is required' : null,
              ),
              const SizedBox(height: 32),
              
              Text(
                "Admin Only - Pricing & Inventory",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38),
              ),
              const SizedBox(height: 16),
              
              _buildModernField(
                controller: _actualPriceController,
                label: "Actual Price (₹)",
                icon: Icons.price_check_outlined,
                hint: "0.00",
                keyboardType: TextInputType.number,
                validator: (v) => v != null && v.isNotEmpty && double.tryParse(v) == null ? 'Invalid price' : null,
              ),
              const SizedBox(height: 20),
              
              _buildModernField(
                controller: _marginPriceController,
                label: "Margin Price (₹)",
                icon: Icons.trending_up_outlined,
                hint: "0.00",
                keyboardType: TextInputType.number,
                validator: (v) => v != null && v.isNotEmpty && double.tryParse(v) == null ? 'Invalid price' : null,
              ),
              const SizedBox(height: 20),
              
              _buildModernField(
                controller: _stockQuantityController,
                label: "Stock Quantity",
                icon: Icons.inventory_2_outlined,
                hint: "0",
                keyboardType: TextInputType.number,
                validator: (v) => v != null && v.isNotEmpty && int.tryParse(v) == null ? 'Invalid quantity' : null,
              ),
              const SizedBox(height: 20),
              
              // Calculated Price Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate_outlined, color: kPrimaryColor, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Calculated Price (Shown to Users)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${_calculatedPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                "Content & Media",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black38),
              ),
              const SizedBox(height: 16),
              
              _buildModernField(
                controller: _descriptionController,
                label: "Description",
                icon: Icons.description_outlined,
                hint: "Describe the taste, ingredients, etc...",
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              
              _buildModernField(
                controller: _imagesController,
                label: "Image URLs",
                icon: Icons.image_search_rounded,
                hint: "https://image1.jpg, https://image2.jpg",
                maxLines: 3,
              ),
              
              const SizedBox(height: 40),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.product == null ? 'Create Product' : 'Save Changes',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kAccentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}