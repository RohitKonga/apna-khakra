import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/auth_provider.dart';
import 'home_screen.dart';
import 'order_history_screen.dart';

// Brand Constants
const kAccentColor = Color(0xFFFF6B35); 
const kPrimaryColor = Color(0xFF2D5A27); 
const kBgColor = Color(0xFFFFF9F2);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.name ?? '');
    _emailController = TextEditingController(text: authProvider.email ?? '');
    _phoneController = TextEditingController(text: authProvider.phone ?? '');
    _addressController = TextEditingController(text: authProvider.address ?? '');
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
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
    setState(() => _isSaving = false);
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: kPrimaryColor),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: _buildElegantAppBar(context),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return Center(
              child: Text('Please sign in to view your profile', 
              style: GoogleFonts.poppins(color: Colors.black45)),
            );
          }

          if (!_isEditing) {
            _nameController.text = auth.name ?? '';
            _emailController.text = auth.email ?? '';
            _phoneController.text = auth.phone ?? '';
            _addressController.text = auth.address ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(auth),
                  const SizedBox(height: 40),
                  
                  // Info Fields
                  _buildProfileField(
                    controller: _nameController,
                    label: "Name",
                    icon: Icons.person_outline_rounded,
                    enabled: _isEditing && !auth.isAdmin,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.alternate_email_rounded,
                    enabled: _isEditing && !auth.isAdmin,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    controller: _phoneController,
                    label: "Phone",
                    icon: Icons.phone_android_rounded,
                    enabled: _isEditing && !auth.isAdmin,
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    controller: _addressController,
                    label: "Shipping Address",
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    enabled: _isEditing && !auth.isAdmin,
                  ),

                  const SizedBox(height: 40),

                  // My Orders Button (only for regular users)
                  if (!auth.isAdmin)
                    _buildOrderHistoryButton(context),

                  const SizedBox(height: 20),

                  if (_isEditing && !auth.isAdmin)
                    _buildActionButton(
                      text: "Save Changes",
                      color: kPrimaryColor,
                      onPressed: _isSaving ? null : _saveProfile,
                      isLoading: _isSaving,
                    )
                  else
                    _buildActionButton(
                      text: "Sign Out",
                      color: Colors.redAccent.shade700,
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildElegantAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kPrimaryColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("Profile Settings", style: GoogleFonts.dmSerifDisplay(color: kPrimaryColor, fontSize: 22)),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isAuthenticated || auth.isAdmin) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit_note, color: kPrimaryColor, size: 28),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _isEditing = false;
                    _nameController.text = auth.name ?? '';
                    _emailController.text = auth.email ?? '';
                    _phoneController.text = auth.phone ?? '';
                    _addressController.text = auth.address ?? '';
                  } else {
                    _isEditing = true;
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(AuthProvider auth) {
    String initials = (auth.name?.isNotEmpty == true) 
        ? auth.name!.substring(0, 1).toUpperCase() 
        : (auth.email?.isNotEmpty == true) ? auth.email!.substring(0, 1).toUpperCase() : 'U';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kAccentColor.withOpacity(0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: kPrimaryColor,
            child: Text(initials, style: GoogleFonts.dmSerifDisplay(fontSize: 40, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          auth.name ?? auth.email ?? 'User',
          style: GoogleFonts.dmSerifDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
        Text(
          auth.isAdmin ? "Administrator" : "Valued Customer",
          style: GoogleFonts.poppins(fontSize: 14, color: kAccentColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildOrderHistoryButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kAccentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shopping_bag_outlined, color: kAccentColor, size: 24),
        ),
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: kPrimaryColor,
          ),
        ),
        subtitle: Text(
          'View order history & track deliveries',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: kPrimaryColor, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black38)),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 15, color: enabled ? Colors.black87 : Colors.black45),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? kPrimaryColor : Colors.black26, size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.black.withOpacity(0.02),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kAccentColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}