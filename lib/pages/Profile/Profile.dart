// lib/pages/Profile/Profile.dart
import 'package:flutter/material.dart';
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
  Map<String, dynamic>? _iqResult; // ← NEW: holds latest IQ result
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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

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

  // ─────────────────────────────────────────────
  // IQ RESULT HELPERS
  // ─────────────────────────────────────────────

  /// Returns the IQ score saved from the last test, or 0 if none.
  int get _iqScore {
    if (_iqResult == null) return 0;
    // data.iq_score
    final data = _iqResult!['data'];
    if (data is Map && data['iq_score'] != null) {
      final v = data['iq_score'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    // summary.iqScore
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['iqScore'] != null) {
      final v = summary['iqScore'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  /// Returns the performance level string (e.g. "Above Average").
  String get _iqPerformance {
    if (_iqResult == null) return 'N/A';
    final data = _iqResult!['data'];
    if (data is Map && data['performance_level'] != null) {
      return data['performance_level'].toString();
    }
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['performanceLevel'] != null) {
      return summary['performanceLevel'].toString();
    }
    return 'N/A';
  }

  /// Returns percentage (0–100) for progress bar & display.
  double get _iqPercentage {
    if (_iqResult == null) return 0.0;
    final data = _iqResult!['data'];
    if (data is Map && data['percentage'] != null) {
      final v = data['percentage'];
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
    }
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['percentage'] != null) {
      final v = summary['percentage'];
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
    }
    return 0.0;
  }

  int get _iqCorrect {
    if (_iqResult == null) return 0;
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['correctAnswers'] != null) {
      final v = summary['correctAnswers'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    final data = _iqResult!['data'];
    if (data is Map && data['correct_answers'] != null) {
      final v = data['correct_answers'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  int get _iqTotal {
    if (_iqResult == null) return 0;
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['totalQuestions'] != null) {
      final v = summary['totalQuestions'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    final data = _iqResult!['data'];
    if (data is Map && data['total_questions'] != null) {
      final v = data['total_questions'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  int get _iqScore_raw {
    if (_iqResult == null) return 0;
    final data = _iqResult!['data'];
    if (data is Map && data['total_score'] != null) {
      final v = data['total_score'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['score'] != null) {
      final v = summary['score'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  int get _iqMaxScore {
    if (_iqResult == null) return 0;
    final data = _iqResult!['data'];
    if (data is Map && data['max_score'] != null) {
      final v = data['max_score'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    final summary = _iqResult!['summary'];
    if (summary is Map && summary['maxScore'] != null) {
      final v = summary['maxScore'];
      return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  /// Maps IQ score to a human-readable category.
  String _iqCategory(int iq) {
    if (iq >= 145) return 'Genius';
    if (iq >= 130) return 'Gifted';
    if (iq >= 120) return 'Superior';
    if (iq >= 110) return 'High Average';
    if (iq >= 90) return 'Average';
    if (iq >= 80) return 'Low Average';
    return 'Below Average';
  }

  /// What fraction of the IQ scale (70–145) this IQ sits at — used for progress bar.
  double _iqProgressFraction(int iq) {
    const min = 70.0;
    const max = 145.0;
    return ((iq.clamp(min.toInt(), max.toInt()) - min) / (max - min))
        .clamp(0.0, 1.0);
  }

  Color _performanceColor(String perf) {
    switch (perf) {
      case 'Exceptional':
        return const Color(0xFF4CAF50);
      case 'Excellent':
        return const Color(0xFF2196F3);
      case 'Above Average':
        return const Color(0xFF00BCD4);
      case 'Average':
        return const Color(0xFFFF9800);
      case 'Below Average':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF0072BC);
    }
  }

  // ─────────────────────────────────────────────
  // DATA LOADING
  // ─────────────────────────────────────────────

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      await AuthTokenManager.instance.getToken();
      final userData = await AuthTokenManager.instance.getUserData();

      _user = userData ??
          {
            'username': 'User',
            'email': '',
            'phone': '',
          };

      // Load last IQ result
      final iqData = await AuthTokenManager.instance.getIQResult();
      _iqResult = iqData;

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
      _user = {'username': 'User', 'email': '', 'phone': ''};
      _usernameController.text = 'User';
      _emailController.text = '';
      _phoneController.text = '';
      _startAnimations();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    final targetFraction =
        _iqScore > 0 ? _iqProgressFraction(_iqScore) : 0.0;
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final progressAnim = Tween<double>(begin: 0, end: targetFraction).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressAnimation = progressAnim;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    try {
      setState(() => _isLoading = true);

      final updatedUser = {
        ..._user!,
        'username': _usernameController.text,
        'name': _usernameController.text,
        'full_name': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'mobile': _phoneController.text,
        'contact': _phoneController.text,
      };

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
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await AuthTokenManager.instance.clearAll();
        if (mounted) Navigator.pushReplacementNamed(context, '/auth');
      } catch (_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/auth');
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

  String _getProfileImage() {
    for (final key in ['profile_image', 'avatar', 'profile_pic']) {
      if (_user?[key] != null) return _user![key].toString();
    }
    return 'https://randomuser.me/api/portraits/men/1.jpg';
  }

  String _getUserInitials() {
    String name = _user?['username']?.toString() ??
        _user?['name']?.toString() ??
        _user?['full_name']?.toString() ??
        'User';
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  double _responsiveValue(double mobile, double tablet, double desktop) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return desktop;
    if (w >= 768) return tablet;
    return mobile;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B5394)))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveValue(16, 20, 24),
                      vertical: _responsiveValue(16, 20, 24),
                    ),
                    child: Column(
                      children: [
                        _animatedCard(_buildPersonalInfoCard()),
                        SizedBox(height: _responsiveValue(16, 20, 24)),
                        _animatedCard(_buildIQScoreCard()),
                        SizedBox(height: _responsiveValue(16, 20, 24)),
                        _animatedCard(_buildSettingsCard()),
                      ],
                    ),
                  ),
                ),
                const Footer(currentIndex: 3),
              ],
            ),
    );
  }

  Widget _animatedCard(Widget child) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) => Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Opacity(opacity: _fadeAnimation.value, child: child),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _responsiveValue(20, 24, 32),
                vertical: _responsiveValue(10, 12, 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _responsiveValue(20, 22, 24),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _isEditing = !_isEditing),
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) =>
                  Transform.scale(scale: _scaleAnimation.value, child: child),
              child: Column(
                children: [
                  Container(
                    width: _responsiveValue(100, 120, 140),
                    height: _responsiveValue(100, 120, 140),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 4),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _getProfileImage(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
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
    );
  }

  // ─────────────────────────────────────────────
  // IQ SCORE CARD (uses real data)
  // ─────────────────────────────────────────────

  Widget _buildIQScoreCard() {
    final hasResult = _iqResult != null && _iqScore > 0;
    final iq = _iqScore;
    final perf = _iqPerformance;
    final pct = _iqPercentage;
    final category = hasResult ? _iqCategory(iq) : '—';

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
          // Header row
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
                  // TODO: navigate to IQ history
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

          if (!hasResult)
            // ── No result yet ──
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 48, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'No IQ test taken yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: _responsiveValue(16, 17, 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete an IQ test to see your results here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: _responsiveValue(13, 14, 15),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ── Has result ──
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IQ Circle
                    Container(
                      width: _responsiveValue(100, 110, 120),
                      height: _responsiveValue(100, 110, 120),
                      margin:
                          EdgeInsets.only(right: _responsiveValue(16, 20, 24)),
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
                            '$iq',
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

                    // Info column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Performance badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _performanceColor(perf).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              perf,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: _responsiveValue(12, 13, 14),
                              ),
                            ),
                          ),
                          SizedBox(height: _responsiveValue(8, 10, 12)),

                          Text(
                            'Category: $category',
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: _responsiveValue(6, 8, 10)),

                          Text(
                            'Score: $_iqScore_raw / $_iqMaxScore',
                            style: TextStyle(
                              fontSize: _responsiveValue(13, 14, 15),
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: _responsiveValue(6, 8, 10)),

                          Text(
                            '$_iqCorrect / $_iqTotal correct  •  ${pct.round()}%',
                            style: TextStyle(
                              fontSize: _responsiveValue(13, 14, 15),
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: _responsiveValue(20, 24, 28)),

                // Progress bar (IQ scale 70 → 145)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Below Average',
                            style: TextStyle(
                              fontSize: _responsiveValue(11, 12, 13),
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            )),
                        Text('Gifted',
                            style: TextStyle(
                              fontSize: _responsiveValue(11, 12, 13),
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: _responsiveValue(8, 9, 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (_, __) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Your IQ: $iq  —  $category',
                        style: TextStyle(
                          fontSize: _responsiveValue(12, 13, 14),
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PERSONAL INFO CARD
  // ─────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    String displayName = _user?['username']?.toString() ??
        _user?['name']?.toString() ??
        _user?['full_name']?.toString() ??
        'User';
    String displayEmail =
        _user?['email']?.toString() ?? 'user@example.com';
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
                  onTap: () => setState(() => _isEditing = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveValue(16, 18, 20),
                      vertical: _responsiveValue(8, 9, 10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5394),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Edit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          SizedBox(height: _responsiveValue(20, 22, 24)),
          _buildInfoSection(
            icon: Icons.person,
            label: 'Full Name',
            value: displayName,
            controller: _usernameController,
            isEditing: _isEditing,
          ),
          SizedBox(height: _responsiveValue(16, 18, 20)),
          _buildInfoSection(
            icon: Icons.email,
            label: 'Email Address',
            value: displayEmail,
            controller: _emailController,
            isEditing: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: _responsiveValue(16, 18, 20)),
          _buildInfoSection(
            icon: Icons.phone,
            label: 'Phone Number',
            value: displayPhone,
            controller: _phoneController,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          if (_isEditing) ...[
            SizedBox(height: _responsiveValue(20, 24, 28)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _usernameController.text = displayName;
                        _emailController.text = displayEmail;
                        _phoneController.text = displayPhone;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                      padding: EdgeInsets.symmetric(
                          vertical: _responsiveValue(12, 14, 16)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        )),
                  ),
                ),
                SizedBox(width: _responsiveValue(10, 12, 16)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B5394),
                      padding: EdgeInsets.symmetric(
                          vertical: _responsiveValue(12, 14, 16)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save Changes',
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
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
        Container(
          width: _responsiveValue(40, 44, 48),
          height: _responsiveValue(40, 44, 48),
          decoration: BoxDecoration(
            color: const Color(0xFF0B5394).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon,
              size: _responsiveValue(20, 22, 24),
              color: const Color(0xFF0B5394)),
        ),
        SizedBox(width: _responsiveValue(12, 14, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: _responsiveValue(12, 13, 14),
                      color: const Color(0xFF666666))),
              const SizedBox(height: 4),
              isEditing
                  ? TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        hintText: 'Enter $label',
                        hintStyle:
                            const TextStyle(color: Color(0xFF999999)),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color(0xFF0B5394)
                                    .withOpacity(0.3))),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color(0xFF0B5394)
                                    .withOpacity(0.3))),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF0B5394), width: 2)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: _responsiveValue(16, 17, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    )
                  : Text(value,
                      style: TextStyle(
                        fontSize: _responsiveValue(16, 17, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      )),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SETTINGS CARD
  // ─────────────────────────────────────────────

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
          Text('Settings',
              style: TextStyle(
                fontSize: _responsiveValue(20, 22, 24),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B5394),
              )),
          SizedBox(height: _responsiveValue(16, 20, 24)),
          _buildSettingItem(
            icon: Icons.security,
            iconColor: const Color(0xFF007AFF),
            title: 'Privacy & Security',
            onTap: () {},
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),
          _buildSettingItem(
            icon: Icons.help_center,
            iconColor: const Color(0xFFFF9500),
            title: 'Help & Support',
            onTap: () {},
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),
          _buildSettingItem(
            icon: Icons.info,
            iconColor: const Color(0xFF5856D6),
            title: 'About',
            onTap: () {},
          ),
          SizedBox(height: _responsiveValue(12, 14, 16)),
          const Divider(),
          SizedBox(height: _responsiveValue(12, 14, 16)),
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
          Container(
            width: _responsiveValue(40, 44, 48),
            height: _responsiveValue(40, 44, 48),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                size: _responsiveValue(22, 24, 26), color: iconColor),
          ),
          SizedBox(width: _responsiveValue(12, 14, 16)),
          Expanded(
            child: Text(title,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                )),
          ),
          if (showArrow)
            Icon(Icons.chevron_right,
                size: _responsiveValue(20, 22, 24),
                color: const Color(0xFF999999)),
        ],
      ),
    );
  }
}