// lib/pages/Profile/Profile.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../widgets/Footer.dart';
import '../../services/auth_token_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _user;
  String? _token;
  bool _isEditing = false;
  bool _isLoading = true;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 0.65).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    // Load user data from SharedPreferences
    _loadUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Read token and user data from secure storage
      _token = await AuthTokenManager.instance.getToken();
      final userData = await AuthTokenManager.instance.getUserData();

      if (userData != null) {
        _user = userData;
      } else {
        // No stored data — use safe defaults
        _user = {
          'username': 'User',
          'email':    '',
          'phone':    '',
        };
      }

      _usernameController.text = _user?['username']?.toString() ??
          _user?['name']?.toString() ??
          _user?['full_name']?.toString() ??
          'User';

      _emailController.text = _user?['email']?.toString() ?? '';

      _phoneController.text = _user?['phone']?.toString() ??
          _user?['mobile']?.toString() ??
          _user?['contact']?.toString() ??
          '';

      _startAnimations();
    } catch (_) {
      // On error, use safe defaults and still show the screen
      _user = {
        'username': 'User',
        'email':    '',
        'phone':    '',
      };
      _usernameController.text = 'User';
      _emailController.text    = '';
      _phoneController.text    = '';
      _startAnimations();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    try {
      setState(() => _isLoading = true);

      final updatedUser = {
        ..._user!,
        'username':  _usernameController.text,
        'name':      _usernameController.text,
        'full_name': _usernameController.text,
        'email':     _emailController.text,
        'phone':     _phoneController.text,
        'mobile':    _phoneController.text,
        'contact':   _phoneController.text,
      };

      // Save updated profile securely
      await AuthTokenManager.instance.saveUserData(updatedUser);

      setState(() {
        _user = updatedUser;
        _isEditing = false;
        _isLoading = false;
      });

      _showSnackBar('Profile updated successfully!', Colors.green);
    } catch (_) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to update profile', Colors.red);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Wipe all auth data from secure storage
        await AuthTokenManager.instance.clearAll();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } catch (_) {
        // Even on error, navigate to auth to prevent stale session
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Get profile image from user data
  String _getProfileImage() {
    if (_user?['profile_image'] != null) {
      return _user!['profile_image'].toString();
    }
    if (_user?['avatar'] != null) {
      return _user!['avatar'].toString();
    }
    if (_user?['profile_pic'] != null) {
      return _user!['profile_pic'].toString();
    }
    return 'https://randomuser.me/api/portraits/men/1.jpg';
  }

  // Get user initials for avatar
  String _getUserInitials() {
    String name = _user?['username']?.toString() ?? 
                  _user?['name']?.toString() ?? 
                  _user?['full_name']?.toString() ?? 
                  'User';
    
    if (name.isEmpty) return 'U';
    
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop;
    if (screenWidth >= 768) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0B5394),
              ),
            )
          : Column(
              children: [
                // Header with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B5394), Color(0xFF1C6CB0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // Header Top Row
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _responsiveValue(20, 24, 32),
                            vertical: _responsiveValue(10, 12, 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              // Title
                              Text(
                                'My Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              // Edit Button
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile Avatar
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: _responsiveValue(100, 120, 140),
                                height: _responsiveValue(100, 120, 140),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 4,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    _getProfileImage(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.blue.shade100,
                                        child: Center(
                                          child: Text(
                                            _getUserInitials(),
                                            style: TextStyle(
                                              fontSize: _responsiveValue(32, 36, 40),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0B5394),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Display Username - Fixed: Extract string value
                              Text(
                                _user?['username']?.toString() ?? 
                                _user?['name']?.toString() ?? 
                                _user?['full_name']?.toString() ?? 
                                'User',
                                style: TextStyle(
                                  fontSize: _responsiveValue(24, 26, 28),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveValue(16, 20, 24),
                      vertical: _responsiveValue(16, 20, 24),
                    ),
                    child: Column(
                      children: [
                        // Personal Information Card
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildPersonalInfoCard(),
                        ),
                        SizedBox(height: _responsiveValue(16, 20, 24)),

                        // IQ Score Card
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildIQScoreCard(),
                        ),
                        SizedBox(height: _responsiveValue(16, 20, 24)),

                        // Settings Card
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildSettingsCard(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                const Footer(
                  currentIndex: 3,
                ),
              ],
            ),
    );
  }

  Widget _buildPersonalInfoCard() {
    // Extract values properly - FIXED: Don't show the whole object
    String displayName = _user?['username']?.toString() ?? 
                         _user?['name']?.toString() ?? 
                         _user?['full_name']?.toString() ?? 
                         'User';
    
    String displayEmail = _user?['email']?.toString() ?? 'user@example.com';
    
    String displayPhone = _user?['phone']?.toString() ?? 
                          _user?['mobile']?.toString() ?? 
                          _user?['contact']?.toString() ?? 
                          '+1 234 567 8900';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: _responsiveValue(20, 22, 24),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B5394),
                ),
              ),
              if (!_isEditing)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveValue(16, 18, 20),
                      vertical: _responsiveValue(8, 9, 10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5394),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: _responsiveValue(20, 22, 24)),

          // Full Name Section - Show extracted value, not whole object
          _buildInfoSection(
            icon: Icons.person,
            label: 'Full Name',
            value: displayName,
            controller: _usernameController,
            isEditing: _isEditing,
          ),
          SizedBox(height: _responsiveValue(16, 18, 20)),

          // Email Section - Show extracted value
          _buildInfoSection(
            icon: Icons.email,
            label: 'Email Address',
            value: displayEmail,
            controller: _emailController,
            isEditing: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: _responsiveValue(16, 18, 20)),

          // Phone Section - Show extracted value
          _buildInfoSection(
            icon: Icons.phone,
            label: 'Phone Number',
            value: displayPhone,
            controller: _phoneController,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),

          // Save/Cancel Buttons (only shown when editing)
          if (_isEditing) ...[
            SizedBox(height: _responsiveValue(20, 24, 28)),
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: _responsiveValue(5, 6, 8),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          // Reset to original values
                          _usernameController.text = displayName;
                          _emailController.text = displayEmail;
                          _phoneController.text = displayPhone;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        padding: EdgeInsets.symmetric(
                          vertical: _responsiveValue(12, 14, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ),
                // Save Button
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: _responsiveValue(5, 6, 8),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B5394),
                        padding: EdgeInsets.symmetric(
                          vertical: _responsiveValue(12, 14, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String value,
    TextEditingController? controller,
    bool isEditing = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container
        Container(
          width: _responsiveValue(40, 44, 48),
          height: _responsiveValue(40, 44, 48),
          decoration: BoxDecoration(
            color: const Color(0xFF0B5394).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: _responsiveValue(20, 22, 24),
            color: const Color(0xFF0B5394),
          ),
        ),
        SizedBox(width: _responsiveValue(12, 14, 16)),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
                  color: const Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              isEditing
                  ? TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        hintText: 'Enter $label',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF0B5394).withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF0B5394).withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF0B5394),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: _responsiveValue(16, 17, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    )
                  : Text(
                      value, // This now shows the actual value, not the whole object
                      style: TextStyle(
                        fontSize: _responsiveValue(16, 17, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIQScoreCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B5394), Color(0xFF1C6CB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5394).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IQ Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IQ Score',
                style: TextStyle(
                  fontSize: _responsiveValue(20, 22, 24),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to IQ history
                },
                child: Text(
                  'View History →',
                  style: TextStyle(
                    fontSize: _responsiveValue(14, 15, 16),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _responsiveValue(16, 20, 24)),

          // IQ Content
          Row(
            children: [
              // IQ Circle
              Container(
                width: _responsiveValue(100, 110, 120),
                height: _responsiveValue(100, 110, 120),
                margin: EdgeInsets.only(right: _responsiveValue(16, 20, 24)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 4,
                  ),
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '121',
                      style: TextStyle(
                        fontSize: _responsiveValue(32, 36, 40),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'IQ',
                      style: TextStyle(
                        fontSize: _responsiveValue(14, 15, 16),
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // IQ Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Higher than ',
                        style: TextStyle(
                          fontSize: _responsiveValue(16, 17, 18),
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: '79%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                          const TextSpan(text: ' of users'),
                        ],
                      ),
                    ),
                    SizedBox(height: _responsiveValue(8, 10, 12)),
                    Text(
                      'Category: Intelligent',
                      style: TextStyle(
                        fontSize: _responsiveValue(14, 15, 16),
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: _responsiveValue(12, 16, 20)),

                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Average',
                              style: TextStyle(
                                fontSize: _responsiveValue(12, 13, 14),
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Gifted',
                              style: TextStyle(
                                fontSize: _responsiveValue(12, 13, 14),
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: _responsiveValue(8, 9, 10)),

                        // Progress Bar
                        Container(
                          height: _responsiveValue(8, 9, 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: _responsiveValue(8, 9, 10)),

                        // Progress Text
                        Center(
                          child: Text(
                            'Your current level',
                            style: TextStyle(
                              fontSize: _responsiveValue(12, 13, 14),
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: _responsiveValue(20, 22, 24),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B5394),
            ),
          ),
          SizedBox(height: _responsiveValue(16, 20, 24)),

          // Settings Items
          _buildSettingItem(
            icon: Icons.security,
            iconColor: const Color(0xFF007AFF),
            title: 'Privacy & Security',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),

          _buildSettingItem(
            icon: Icons.help_center,
            iconColor: const Color(0xFFFF9500),
            title: 'Help & Support',
            onTap: () {
              // Navigate to help & support
            },
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),

          _buildSettingItem(
            icon: Icons.info,
            iconColor: const Color(0xFF5856D6),
            title: 'About',
            onTap: () {
              // Navigate to about
            },
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),

          const Divider(),
          SizedBox(height: _responsiveValue(12, 14, 16)),

          // Logout Item
          _buildSettingItem(
            icon: Icons.logout,
            iconColor: const Color(0xFFFF3B30),
            title: 'Logout',
            textColor: const Color(0xFFFF3B30),
            showArrow: false,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color textColor = const Color(0xFF333333),
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Icon Container
          Container(
            width: _responsiveValue(40, 44, 48),
            height: _responsiveValue(40, 44, 48),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: _responsiveValue(22, 24, 26),
              color: iconColor,
            ),
          ),
          SizedBox(width: _responsiveValue(12, 14, 16)),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _responsiveValue(16, 17, 18),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          
          // Arrow
          if (showArrow)
            Icon(
              Icons.chevron_right,
              size: _responsiveValue(20, 22, 24),
              color: const Color(0xFF999999),
            ),
        ],
      ),
    );
  }
}