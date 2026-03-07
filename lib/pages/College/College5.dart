// lib/pages/College/College5.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../Widgets/Footer.dart';
import '../../Api/School/Colleges/College_service.dart';
import '../../components/glass_loader.dart';
import '../../services/auth_token_manager.dart';

class College5Screen extends StatefulWidget {
  final Map<String, dynamic> college;

  const College5Screen({
    super.key,
    required this.college,
  });

  @override
  State<College5Screen> createState() => _College5ScreenState();
}

class _College5ScreenState extends State<College5Screen> {
  // ─── Base URL ──────────────────────────────────────────────────────────────
  static const String _baseUrl = 'https://master-backend-18ik.onrender.com';

  // ─── UI State ──────────────────────────────────────────────────────────────
  int _footerIndex = 0;
  int _activeAd = 0;
  String _activeTab = "Placement";
  final PageController _adController = PageController();
  Timer? _adTimer;

  // ─── Auth ──────────────────────────────────────────────────────────────────
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  bool _isLoggedIn = false;
  int? _currentUserId;
  String? _currentUserName;
  bool _isAuthChecking = true;

  // ─── Review Form ───────────────────────────────────────────────────────────
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _hasUserReviewed = false;

  // ─── Reviews Data ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;
  bool _isLoadingReviews = true;
  String? _reviewsError;

  // ─── Ads & Videos ──────────────────────────────────────────────────────────
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;
  bool _isLoadingAds = true;

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  // ─── Tabs ──────────────────────────────────────────────────────────────────
  final List<String> tabs = [
    "All",
    "Dept",
    "Placement",
    "Academic",
    "Facilities",
    "Admission",
    "About"
  ];

  // ─── Responsive (set in build) ─────────────────────────────────────────────
  late bool _isTablet;
  late bool _isDesktop;
  late double _horizontalPadding;
  late double _bannerHeight;
  late double _maxContentWidth;

  // ═══════════════════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadAdvertisements();
    _loadLocalReviews();
    _fetchReviews();

    // Auto-scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAd + 1;
        if (nextPage >= bannerAds.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkAuthStatus() async {
    setState(() => _isAuthChecking = true);
    try {
      final hasToken = await _authManager.hasToken();
      final userData = await _authManager.getUserData();
      final userName = await _authManager.getUsername();

      if (mounted) {
        setState(() {
          _isLoggedIn = hasToken;
          _currentUserId =
              userData != null ? userData['id'] as int? : null;
          _currentUserName = userName;
          _isAuthChecking = false;
        });
        _checkIfUserReviewed();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _currentUserId = null;
          _currentUserName = null;
          _isAuthChecking = false;
        });
      }
    }
  }

  void _checkIfUserReviewed() {
    if (_currentUserId == null || _reviews.isEmpty) {
      setState(() => _hasUserReviewed = false);
      return;
    }
    final exists = _reviews.any((r) => r['userId'] == _currentUserId);
    setState(() => _hasUserReviewed = exists);
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/auth').then((_) {
      _checkAuthStatus();
      _loadLocalReviews();
      _fetchReviews();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  COLLEGE ID HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  int? _getCollegeId() {
    final id = widget.college['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  LOCAL REVIEW STORAGE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadLocalReviews() async {
    final collegeId = _getCollegeId();
    if (collegeId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reviewsJson =
          prefs.getString('reviews_college_$collegeId');

      if (reviewsJson != null) {
        final List<dynamic> decoded = jsonDecode(reviewsJson);
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(decoded);
          _totalReviews = _reviews.length;
          _calculateAverageRating();
        });
        if (_currentUserId != null) _checkIfUserReviewed();
      }
    } catch (e) {
      debugPrint('Error loading local reviews: $e');
    }
  }

  Future<void> _saveLocalReviews() async {
    final collegeId = _getCollegeId();
    if (collegeId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'reviews_college_$collegeId', jsonEncode(_reviews));
    } catch (e) {
      debugPrint('Error saving local reviews: $e');
    }
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    double sum = 0.0;
    for (var review in _reviews) {
      final r = review['rating'];
      if (r is int) sum += r.toDouble();
      else if (r is double) sum += r;
      else if (r is String) sum += double.tryParse(r) ?? 0.0;
    }
    _averageRating = sum / _reviews.length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  FETCH REVIEWS FROM API
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _fetchReviews() async {
    final collegeId = _getCollegeId();
    if (collegeId == null) {
      setState(() => _isLoadingReviews = false);
      return;
    }

    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final token = await _authManager.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/api/college-reviews/$collegeId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 College Reviews Status: ${response.statusCode}');
      debugPrint('📡 College Reviews Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Support both { reviews: [...], totalReviews: N }
        // and plain list response
        List<dynamic> reviewsList = [];
        int total = 0;

        if (jsonResponse.containsKey('reviews') &&
            jsonResponse['reviews'] is List) {
          reviewsList = jsonResponse['reviews'];
          total = jsonResponse['totalReviews'] ?? reviewsList.length;
        } else if (jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          reviewsList = jsonResponse['data'];
          total = reviewsList.length;
        }

        final formatted = <Map<String, dynamic>>[];
        for (var review in reviewsList) {
          if (review is Map<String, dynamic>) {
            int? userId;
            if (review['userId'] is int) {
              userId = review['userId'] as int;
            } else if (review['userId'] is String) {
              userId = int.tryParse(review['userId'].toString());
            }

            formatted.add({
              'id': review['id'] ?? 0,
              'userId': userId,
              'userName': review['username'] ?? 'Anonymous',
              'rating': review['rating'] ?? 0,
              'review': review['review'] ?? '',
              'createdAt':
                  review['createdAt'] ?? DateTime.now().toIso8601String(),
            });
          }
        }

        setState(() {
          _reviews = formatted;
          _totalReviews = total;
          _calculateAverageRating();
          _isLoadingReviews = false;
        });

        await _saveLocalReviews();
        if (_currentUserId != null) _checkIfUserReviewed();
      } else if (response.statusCode == 404) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _reviewsError = 'Failed to load reviews (${response.statusCode})';
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching reviews: $e');
      setState(() {
        _reviewsError = 'Error loading reviews';
        _isLoadingReviews = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SUBMIT REVIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _submitReview() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      _showDialog('Incomplete', 'Please give a rating and write your review.');
      return;
    }

    if (!_isLoggedIn) {
      _showDialog('Login Required', 'Please login to submit a review.');
      return;
    }

    if (_hasUserReviewed) {
      _showDialog(
          'Already Reviewed', 'You have already reviewed this college.');
      return;
    }

    final collegeId = _getCollegeId();
    if (collegeId == null) {
      _showDialog('Error', 'College information is missing.');
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final token = await _authManager.getToken();

      if (token == null) {
        _showDialog('Login Required', 'Please login to submit a review.');
        setState(() => _isSubmittingReview = false);
        return;
      }

      // Optimistic local review
      final newReview = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'userId': _currentUserId,
        'userName': _currentUserName ?? 'Anonymous User',
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/college-reviews'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'collegeId': collegeId,
            'rating': _rating,
            'review': _reviewController.text.trim(),
          }),
        );

        debugPrint(
            '📡 Submit Review: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final res = jsonDecode(response.body);
            if (res is Map && res.containsKey('id')) {
              newReview['id'] = res['id'];
            }
          } catch (_) {}
        } else if (response.statusCode == 409 ||
            response.statusCode == 400) {
          setState(() {
            _hasUserReviewed = true;
            _isSubmittingReview = false;
          });
          _showDialog('Already Reviewed',
              'You have already submitted a review for this college. Each user can only post one review.');
          return;
        } else {
          debugPrint(
              '⚠️ API submission failed ${response.statusCode}, saving locally.');
        }
      } catch (e) {
        debugPrint('Network error, saving locally: $e');
      }

      setState(() {
        _reviews.insert(0, newReview);
        _totalReviews = _reviews.length;
        _calculateAverageRating();
        _rating = 0;
        _reviewController.clear();
        _hasUserReviewed = true;
        _isSubmittingReview = false;
      });

      await _saveLocalReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmittingReview = false);
      _showDialog('Error', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ADS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for collegepage5...');
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/advertisements?page=collegepage5'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          setState(() {
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
            _isLoadingAds = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _nextVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % _youtubeUrls.length;
    });
  }

  void _previousVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex =
          (_currentVideoIndex - 1 + _youtubeUrls.length) % _youtubeUrls.length;
    });
  }

  String _getVideoThumbnail(String url) {
    if (url.contains('youtube.com/embed/')) {
      final videoId = url.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return url;
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} year(s) ago';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} month(s) ago';
      if (diff.inDays > 0) return '${diff.inDays} day(s) ago';
      if (diff.inHours > 0) return '${diff.inHours} hour(s) ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minute(s) ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  void _openMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Opening map...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _callNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Calling...'), duration: Duration(seconds: 2)),
    );
  }

  void _openWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Opening WhatsApp...'),
          duration: Duration(seconds: 2)),
    );
  }

  // ─── Responsive helpers ────────────────────────────────────────────────────

  double _getHeaderHeight(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 64;
    if (w >= 768) return 58;
    return 52;
  }

  double _getTitleFontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 19;
    if (w >= 768) return 18;
    return 17;
  }

  double _getHorizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1024) return 32;
    if (w >= 768) return 24;
    return 16;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TAB CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _renderContent() {
    final fullData = widget.college['fullData'] as CollegeInfo?;
    String contentText = 'Details not available.';

    if (fullData != null) {
      switch (_activeTab) {
        case 'About':
          contentText = fullData.aboutCollege.isEmpty
              ? 'Details not available.'
              : fullData.aboutCollege;
          break;
        case 'Academic':
          contentText = fullData.academics.isEmpty
              ? 'Details not available.'
              : fullData.academics;
          break;
        case 'Facilities':
          contentText = fullData.facilities.isNotEmpty
              ? fullData.facilities.join(', ')
              : 'Details not available.';
          break;
        case 'Admission':
          contentText = fullData.admissionInfo.isEmpty
              ? 'Details not available.'
              : fullData.admissionInfo;
          break;
      }
    }

    if (_activeTab != "Placement" &&
        _activeTab != "Dept" &&
        _activeTab != "All") {
      return _buildSectionCard(
        title: _activeTab,
        child: Text(
          contentText,
          style: TextStyle(
            fontSize: _isTablet ? 15 : 13,
            color: const Color(0xFF5F6F81),
            height: 1.5,
          ),
        ),
      );
    }

    if (_activeTab == "All") {
      return _buildSectionCard(
        title: 'Overview',
        child: Text(
          fullData?.aboutCollege ?? 'Details not available.',
          style: TextStyle(
            fontSize: _isTablet ? 15 : 13,
            color: const Color(0xFF5F6F81),
            height: 1.5,
          ),
        ),
      );
    }

    if (_activeTab == "Dept") {
      return _buildSectionCard(
        title: 'Departments',
        child: Text(
          fullData?.departments.isNotEmpty == true
              ? fullData!.departments.map((d) => '• $d').join('\n')
              : 'No departments listed.',
          style: TextStyle(
            fontSize: _isTablet ? 15 : 13,
            color: const Color(0xFF5F6F81),
            height: 1.5,
          ),
        ),
      );
    }

    // Placement
    return _buildSectionCard(
      title: 'Placement',
      child: Text(
        fullData?.placementInfo?.isNotEmpty == true
            ? fullData!.placementInfo
            : 'Details not available.',
        style: TextStyle(
          fontSize: _isTablet ? 15 : 13,
          color: const Color(0xFF5F6F81),
          height: 1.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    _isTablet = screenWidth >= 768;
    _isDesktop = screenWidth >= 1024;
    _horizontalPadding = _getHorizontalPadding(context);
    _bannerHeight = _isDesktop ? 300 : (_isTablet ? 300 : 200);
    _maxContentWidth = _isDesktop ? 1200 : double.infinity;

    final double bodyFontSize = _isTablet ? 15 : 13;
    final double smallFontSize = _isTablet ? 13 : 11;
    final double cardPadding = _isTablet ? 20 : 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0052A2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                borderRadius: _isDesktop
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: _maxContentWidth),
                padding:
                    EdgeInsets.symmetric(horizontal: _horizontalPadding),
                height: _getHeaderHeight(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            size: 24, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'College Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // ── MAIN CONTENT ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: _maxContentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── BANNER ADS ─────────────────────────────────────
                        Container(
                          margin: EdgeInsets.only(
                              top: _isDesktop ? 8 : 0),
                          child: ClipRRect(
                            borderRadius: _isDesktop
                                ? BorderRadius.circular(12)
                                : BorderRadius.zero,
                            child: SizedBox(
                              height: _bannerHeight,
                              child: PageView.builder(
                                controller: _adController,
                                itemCount: bannerAds.length,
                                onPageChanged: (index) =>
                                    setState(() => _activeAd = index),
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: const Color(0xFFF0F0F0),
                                    child: Image.network(
                                      bannerAds[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, p) {
                                        if (p == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                              color: Color(0xFF0B5ED7)),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.image,
                                                size: 60,
                                                color: Color(0xFF0B5ED7)),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Advertisement ${index + 1}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xFF0B5ED7),
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Dots indicator
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(bannerAds.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeAd == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 6),
                              decoration: BoxDecoration(
                                color: _activeAd == index
                                    ? const Color(0xFF0B5ED7)
                                    : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // ── HERO CARD ──────────────────────────────────────
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 20 : 16,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          padding: EdgeInsets.all(_isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius: BorderRadius.circular(
                                _isTablet ? 20 : 18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.college['name'] ?? 'College Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _isDesktop
                                      ? 26
                                      : (_isTablet ? 24 : 20),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.college['category'] ?? ''} · ${(widget.college['type'] ?? '').toString().replaceAll('Govt', 'Government')} Institution',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: _isTablet ? 14 : 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Average rating from reviews
                              if (_averageRating > 0) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16,
                                        color: Color(0xFFFFB703)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _averageRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _isTablet ? 14 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_totalReviews > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '($_totalReviews reviews)',
                                        style: TextStyle(
                                          color:
                                              const Color(0xFFE8F0FF),
                                          fontSize: _isTablet ? 13 : 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  Icon(Icons.school,
                                      size: _isTablet ? 18 : 16,
                                      color: const Color(0xFFE8F0FF)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.college['degreeName'] ?? ''} Programs',
                                    style: TextStyle(
                                      color: const Color(0xFFE8F0FF),
                                      fontSize: _isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: _isTablet ? 18 : 16,
                                      color: const Color(0xFFE8F0FF)),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.college['location'] ??
                                        'Location',
                                    style: TextStyle(
                                      color: const Color(0xFFE8F0FF),
                                      fontSize: _isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── TABS ───────────────────────────────────────────
                        Container(
                          height: _isTablet ? 60 : 50,
                          margin: EdgeInsets.only(
                              top: _isTablet ? 12 : 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tabs.length,
                            itemBuilder: (context, index) {
                              final tab = tabs[index];
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _activeTab = tab),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _isTablet ? 18 : 16,
                                    vertical: _isTablet ? 10 : 8,
                                  ),
                                  margin: EdgeInsets.only(
                                    left: index == 0
                                        ? _horizontalPadding
                                        : 0,
                                    right: index == tabs.length - 1
                                        ? _horizontalPadding
                                        : 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _activeTab == tab
                                        ? const Color(0xFF0B5ED7)
                                        : const Color(0xFFE8F0FF),
                                    borderRadius: BorderRadius.circular(
                                        _isTablet ? 22 : 20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        fontSize: _isTablet ? 15 : 14,
                                        color: _activeTab == tab
                                            ? Colors.white
                                            : const Color(0xFF0B5ED7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // ── TAB CONTENT ────────────────────────────────────
                        _renderContent(),

                        // ── MAP BUTTON ─────────────────────────────────────
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 20 : 16,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          child: ElevatedButton(
                            onPressed: _openMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B5ED7),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map,
                                    size: _isTablet ? 20 : 18),
                                const SizedBox(width: 8),
                                Text(
                                  'View on Map',
                                  style: TextStyle(
                                    fontSize: _isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── CALL & WHATSAPP ────────────────────────────────
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            _isDesktop ? 0 : _horizontalPadding,
                            _isTablet ? 12 : 10,
                            _isDesktop ? 0 : _horizontalPadding,
                            0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _callNow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFE53E3E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: _isTablet ? 16 : 14),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.call,
                                          size: _isTablet ? 20 : 18),
                                      const SizedBox(width: 8),
                                      Text('Call',
                                          style: TextStyle(
                                              fontSize:
                                                  _isTablet ? 16 : 14,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: _isTablet ? 12 : 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _openWhatsApp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: _isTablet ? 16 : 14),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.message,
                                          size: _isTablet ? 20 : 18),
                                      const SizedBox(width: 8),
                                      Text('WhatsApp',
                                          style: TextStyle(
                                              fontSize:
                                                  _isTablet ? 16 : 14,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── RATE & REVIEW ──────────────────────────────────
                        _buildSectionCard(
                          title: 'Rate & Review',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Auth checking
                              if (_isAuthChecking)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: GlassLoader(),
                                  ),
                                )

                              // Not logged in
                              else if (!_isLoggedIn)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Login to share your experience',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _navigateToLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0B5ED7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),
                                        ),
                                        child: const Text(
                                            'Login to Review'),
                                      ),
                                    ],
                                  ),
                                )

                              // Already reviewed
                              else if (_hasUserReviewed)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.orange),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.orange[700]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'You have already reviewed this college',
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Each user can only post one review. Thank you for your feedback!',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )

                              // Review form
                              else ...[
                                Text(
                                  'Rate your experience',
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      onPressed: _isSubmittingReview
                                          ? null
                                          : () => setState(
                                              () => _rating = index + 1),
                                      icon: Icon(
                                        index < _rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: _isTablet ? 34 : 30,
                                        color: const Color(0xFFFFD700),
                                      ),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFF),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE0E7FF)),
                                  ),
                                  child: TextField(
                                    controller: _reviewController,
                                    maxLines: 4,
                                    minLines: 3,
                                    enabled: !_isSubmittingReview,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Share your experience...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: bodyFontSize,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.all(cardPadding),
                                    ),
                                    style:
                                        TextStyle(fontSize: bodyFontSize),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmittingReview
                                        ? null
                                        : _submitReview,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF0B5ED7),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              _isTablet ? 14 : 12),
                                      elevation: 2,
                                    ),
                                    child: _isSubmittingReview
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: GlassLoader(),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.send,
                                                  size: _isTablet
                                                      ? 20
                                                      : 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Submit Review',
                                                style: TextStyle(
                                                  fontSize: _isTablet
                                                      ? 16
                                                      : 14,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── STUDENT REVIEWS LIST ───────────────────────────
                        _buildSectionCard(
                          title:
                              'Student Reviews (${_reviews.length})',
                          child: _isLoadingReviews
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: GlassLoader(),
                                  ),
                                )
                              : _reviewsError != null
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red[300]),
                                            const SizedBox(height: 8),
                                            Text(
                                              _reviewsError!,
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                              textAlign: TextAlign.center,
                                            ),
                                            TextButton(
                                              onPressed: _fetchReviews,
                                              child:
                                                  const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : _reviews.isEmpty
                                      ? Container(
                                          padding:
                                              const EdgeInsets.all(20),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .rate_review_outlined,
                                                    size: 48,
                                                    color: Colors
                                                        .grey[400]),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'No reviews yet',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey[600],
                                                      fontSize: 16),
                                                ),
                                                if (_isLoggedIn &&
                                                    !_hasUserReviewed)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .only(top: 6),
                                                    child: Text(
                                                      'Be the first to review!',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500],
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children:
                                              _reviews.map((review) {
                                            // normalise rating to int
                                            int ratingVal = 0;
                                            final r = review['rating'];
                                            if (r is int) ratingVal = r;
                                            else if (r is double) ratingVal = r.round();
                                            else if (r is String) ratingVal = int.tryParse(r) ?? 0;

                                            return Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets
                                                  .only(bottom: 12),
                                              padding: EdgeInsets.all(
                                                  cardPadding),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                    0xFFF8FAFF),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                border: const Border(
                                                  left: BorderSide(
                                                    color: Color(
                                                        0xFF0B5ED7),
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          review['userName']
                                                                  ?.toString() ??
                                                              'Anonymous',
                                                          style: TextStyle(
                                                            fontSize:
                                                                bodyFontSize,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                            color: const Color(
                                                                0xFF004780),
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: List
                                                            .generate(
                                                                5,
                                                                (i) => Icon(
                                                                      i < ratingVal
                                                                          ? Icons
                                                                              .star
                                                                          : Icons
                                                                              .star_outline,
                                                                      color: const Color(
                                                                          0xFFFFD700),
                                                                      size:
                                                                          smallFontSize,
                                                                    )),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                      height: 8),
                                                  Text(
                                                    review['review']
                                                            ?.toString() ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          smallFontSize,
                                                      color: const Color(
                                                          0xFF5F6F81),
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  if (review['createdAt'] !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 6),
                                                      child: Text(
                                                        _formatDate(review[
                                                                'createdAt']
                                                            .toString()),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey[500],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                        ),

                        // ── YOUTUBE VIDEOS ─────────────────────────────────
                        if (_youtubeUrls.isNotEmpty) ...[
                          if (_youtubeUrls.length > 1)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _horizontalPadding,
                                vertical: _isTablet ? 16 : 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Videos',
                                    style: TextStyle(
                                      fontSize: _isDesktop ? 22 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _previousVideo,
                                        icon: const Icon(
                                            Icons.chevron_left,
                                            color: Color(0xFF0B5ED7)),
                                      ),
                                      Text(
                                        '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                        style: const TextStyle(
                                          color: Color(0xFF0B5ED7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _nextVideo,
                                        icon: const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF0B5ED7)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: _youtubeUrls.length > 1
                                  ? 0
                                  : (_isTablet ? 40 : 32),
                            ),
                            child: CommonYoutubePlayer(
                              youtubeUrl:
                                  _youtubeUrls[_currentVideoIndex],
                              height: _isDesktop
                                  ? 400
                                  : (_isTablet ? 320 : 250),
                              placeholderThumbnail: _getVideoThumbnail(
                                  _youtubeUrls[_currentVideoIndex]),
                              borderRadius: 0,
                            ),
                          ),
                        ] else
                          Padding(
                            padding: EdgeInsets.only(
                                top: _isTablet ? 40 : 32),
                            child: CommonYoutubePlayer(
                              youtubeUrl:
                                  'https://www.youtube.com/embed/NONufn3jgXI',
                              height: _isDesktop
                                  ? 400
                                  : (_isTablet ? 320 : 250),
                              placeholderThumbnail:
                                  'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                              borderRadius: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── FOOTER ──────────────────────────────────────────────────────
            Footer(
              currentIndex: _footerIndex,
              onItemTapped: (index) =>
                  setState(() => _footerIndex = index),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        _isDesktop ? 0 : _horizontalPadding,
        _isTablet ? 20 : 16,
        _isDesktop ? 0 : _horizontalPadding,
        0,
      ),
      padding: EdgeInsets.all(_isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_isTablet ? 18 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _isTablet ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF004780),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}