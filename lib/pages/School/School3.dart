// lib/pages/School/School3.dart
import 'package:flutter/material.dart';
import 'package:master/components/glass_loader.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/School/review_service.dart';
import '../../Api/School/school_service.dart';
import '../../Api/baseurl.dart';
import '../../services/auth_token_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

// ==================== SCHOOL DETAILS SCREEN ====================
class School3Screen extends StatefulWidget {
  final Map<String, dynamic>? school;

  const School3Screen({super.key, this.school});

  @override
  State<School3Screen> createState() => _School3ScreenState();
}

class _School3ScreenState extends State<School3Screen> {
  // Advertisement Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentAd = 0;
  int _currentVideoIndex = 0;
  
  // Default ads (fallback if API fails)
  final List<String> defaultAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200',
  ];

  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  Timer? _timer;
  int _footerIndex = 0;
  
  final PageController _pageController = PageController();
  
  // Reviews from API
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;
  
  bool _isLoading = false;
  bool _isSubmittingReview = false;
  String? _errorMessage;
  Map<String, dynamic>? _fetchedSchool;
  
  // Authentication using AuthTokenManager
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  bool _isLoggedIn = false;
  int? _currentUserId;
  bool _hasUserReviewed = false;
  bool _isAuthChecking = true;

  List<String> get ads => _adImages.isNotEmpty ? _adImages : defaultAds;

  Map<String, dynamic> get school => _fetchedSchool ?? widget.school ?? {
    'schoolName': 'Loading school...',
    'location': '',
    'about': '',
    'rating': '0.0',
    'result': '',
    'classes': [],
    'classesOffered': [],
    'teachingMode': [],
    'category': [],
    'mobileNumber': '',
    'whatsappNumber': '',
    'mapLink': '',
    'schoolLogo': '',
  };

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    _checkAuthStatus();
    if (widget.school != null && widget.school!['id'] != null) {
      _loadSchoolDetails(widget.school!['id']);
    }
    _startAdAutoScroll();
  }

  Future<void> _loadAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=schoolpage3'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          
          setState(() {
            // Parse images
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            
            // Parse youtube URLs
            if (apiData['youtube_urls'] != null && apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading advertisements: $e');
      // Continue with default ads
    }
  }

  void _startAdAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPage = _currentAd + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isAuthChecking = true;
    });

    try {
      final hasToken = await _authManager.hasToken();
      final userData = await _authManager.getUserData();
      
      if (mounted) {
        setState(() {
          _isLoggedIn = hasToken;
          _currentUserId = userData != null ? userData['id'] as int? : null;
          _isAuthChecking = false;
        });
      }
      
      // Load reviews after auth check
      _loadReviews();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _currentUserId = null;
          _isAuthChecking = false;
        });
        _loadReviews();
      }
    }
  }

  Future<void> _loadSchoolDetails(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await SchoolService().fetchSchoolById(id);
      if (mounted) {
        setState(() {
          _fetchedSchool = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    if (widget.school == null || widget.school!['id'] == null) return;

    try {
      // Fetch reviews
      final reviews = await ReviewService().getEntityReviews(
        entityType: 'school',
        entityId: widget.school!['id'],
      );

      // Fetch average rating
      final avgData = await ReviewService().getAverageRating(
        entityType: 'school',
        entityId: widget.school!['id'],
      );

      // Format reviews
      final formattedReviews = reviews.map((r) => ReviewService().formatReview(r)).toList();

      // Get average rating and total from response
      double avgRating = 0.0;
      int totalReviews = reviews.length;
      
      if (avgData['averageRating'] != null) {
        avgRating = (avgData['averageRating'] as num).toDouble();
      }
      if (avgData['totalReviews'] != null) {
        totalReviews = avgData['totalReviews'] as int;
      }

      // Check if current user has reviewed
      bool userReviewed = false;
      if (_currentUserId != null) {
        userReviewed = formattedReviews.any((r) => r['userId'] == _currentUserId);
      }

      if (mounted) {
        setState(() {
          _reviews = formattedReviews;
          _averageRating = avgRating;
          _totalReviews = totalReviews;
          _hasUserReviewed = userReviewed;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error loading reviews: $e');
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      _showDialog('Incomplete', 'Please give rating and write review');
      return;
    }

    if (!_isLoggedIn) {
      _showDialog('Login Required', 'Please login to submit a review');
      return;
    }

    if (_hasUserReviewed) {
      _showDialog('Already Reviewed', 'You have already reviewed this school');
      return;
    }

    if (widget.school == null || widget.school!['id'] == null) {
      _showDialog('Error', 'School information is missing');
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      await ReviewService().addReview(
        entityType: 'school',
        entityId: widget.school!['id'],
        rating: _rating,
        review: _reviewController.text.trim(),
      );

      // Clear form
      setState(() {
        _rating = 0;
        _reviewController.clear();
      });

      // Reload reviews
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ReviewException catch (e) {
      if (e.statusCode == 409 || e.statusCode == 400) {
        // User has already reviewed - update local state
        setState(() {
          _hasUserReviewed = true;
        });
        
        if (mounted) {
          _showDialog('Already Reviewed', 
            'You have already submitted a review for this school. Each user can only post one review.'
          );
        }
      } else {
        if (mounted) {
          _showDialog('Error', e.message);
        }
      }
    } catch (e) {
      if (mounted) {
        _showDialog('Error', e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }
    }
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

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login').then((_) {
      _checkAuthStatus();
    });
  }

  void _handleFooterNavigation(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
      case 2:
      case 3:
        break;
    }
  }

  void _nextVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % _youtubeUrls.length;
    });
  }

  void _previousVideo() {
    if (_youtubeUrls.isEmpty) return;
    setState(() {
      _currentVideoIndex = (_currentVideoIndex - 1 + _youtubeUrls.length) % _youtubeUrls.length;
    });
  }

  String _getVideoThumbnail(String url) {
    if (url.contains('youtube.com/embed/')) {
      final videoId = url.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return url;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _openMap() {
    final mapUrl = school['mapLink'] ?? '';
    if (mapUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening map for ${school['schoolName']}...'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map location not available')),
      );
    }
  }

  void _callNow() {
    final phone = school['mobileNumber'] ?? '';
    if (phone.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Call School'),
          content: Text('Call ${school['schoolName']} at $phone?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Call'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  }

  void _openWhatsApp() {
    final whatsapp = school['whatsappNumber'] ?? '';
    if (whatsapp.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('WhatsApp'),
          content: Text('Open WhatsApp chat with ${school['schoolName']} ($whatsapp)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number not available')),
      );
    }
  }

  Widget _buildChip(String label, bool isMobile, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF374151),
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTeachingModeChip(String label, bool isMobile, bool isTablet, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label.toLowerCase().contains('online') ? Icons.videocam_outlined : Icons.person_outline,
            size: 16,
            color: const Color(0xFF0369A1),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF0369A1),
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    double getHeaderHeight() {
      if (isDesktop) return 64;
      if (isTablet) return 58;
      return 52;
    }

    double getTitleFontSize() {
      if (isDesktop) return 19;
      if (isTablet) return 18;
      return 17;
    }

    double getHorizontalPadding() {
      if (isDesktop) return 40;
      if (isTablet) return 24;
      return 16;
    }

    double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Container(
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
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPadding(),
        ),
        height: getHeaderHeight(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "School Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getTitleFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _fetchedSchool == null && widget.school == null) {
      return const Scaffold(
        body: Center(child: GlassLoader()),
      );
    }

    if (_errorMessage != null && widget.school == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: () {
                  if (widget.school != null && widget.school!['id'] != null) {
                    _loadSchoolDetails(widget.school!['id']);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    final double bannerHeight = isMobile ? 180 : isTablet ? 300 : 300;
    final double videoHeight = isMobile ? 200 : isTablet ? 0 : 350;
    
    final double horizontalPadding = 16.0;
    final double cardPadding = isMobile ? 16 : isTablet ? 18 : 22;

    // Parse rating
    double ratingValue = _averageRating > 0 ? _averageRating : 0.0;
    try {
      final r = school['rating'];
      if (ratingValue == 0.0 && r != null) {
        if (r is double) {
          ratingValue = r;
        } else {
          ratingValue = double.parse(r.toString());
        }
      }
    } catch (e) {
      // Keep existing value
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Ads from API
                    SizedBox(
                      height: bannerHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: ads.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentAd = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                            ),
                            child: Image.network(
                              ads[index],
                              width: screenWidth,
                              height: bannerHeight,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: screenWidth,
                                  height: bannerHeight,
                                  color: const Color(0xFF0052A2),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Advertisement ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: screenWidth,
                                  height: bannerHeight,
                                  color: const Color(0xFF0052A2),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Dots Indicator
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(ads.length, (index) {
                        return Container(
                          width: _currentAd == index ? 16 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentAd == index 
                              ? const Color(0xFF0B5ED7) 
                              : const Color(0xFFCCCCCC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Main Content Container
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Hero Card
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0052A2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // School Logo and Name Row
                                Row(
                                  children: [
                                    if (school['schoolLogo'] != null && school['schoolLogo'].toString().isNotEmpty)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        margin: const EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Builder(
                                            builder: (context) {
                                              if (kDebugMode) {
                                                debugPrint('[DEBUG SCHOOL 3] Logo for ${school['schoolName']}: ${school['schoolLogo']}');
                                              }
                                              return Image.network(
                                                school['schoolLogo'].toString(),
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    color: Colors.white.withOpacity(0.1),
                                                    child: const Center(
                                                      child: GlassLoader(),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: Colors.red[50],
                                                  child: const Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        school['schoolName'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isMobile ? 20 : isTablet ? 22 : 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Rating and Result
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF9E6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Color(0xFFFFB703),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ratingValue.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          if (_totalReviews > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '($_totalReviews)',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        school['result'] ?? '',
                                        style: TextStyle(
                                          color: const Color(0xFFE8F0FF),
                                          fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: const Color(0xFFE8F0FF),
                                      size: isMobile ? 16 : isTablet ? 18 : 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        school['location'] ?? '',
                                        style: TextStyle(
                                          color: const Color(0xFFE8F0FF),
                                          fontSize: isMobile ? 12 : isTablet ? 14 : 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Category Tags
                                if (school['category'] != null && (school['category'] as List).isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (school['category'] as List).map((cat) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          cat.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Classes Offered
                          if (school['classes'] != null && (school['classes'] as List).isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Classes Offered',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (school['classes'] as List).map((className) {
                                      return _buildChip(className.toString(), isMobile, isTablet, isDesktop);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Teaching Mode
                          if (school['teachingMode'] != null && (school['teachingMode'] as List).isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Teaching Mode',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (school['teachingMode'] as List).map((mode) {
                                      return _buildTeachingModeChip(mode.toString(), isMobile, isTablet, isDesktop);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Extracurricular Activities
                          if (school['classesOffered'] != null && (school['classesOffered'] as List).isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Extracurricular Activities',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (school['classesOffered'] as List).map((activity) {
                                      return _buildChip(activity.toString(), isMobile, isTablet, isDesktop);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // View Map Button
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: ElevatedButton(
                              onPressed: _openMap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B5ED7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : isTablet ? 16 : 18),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: Colors.white,
                                    size: isMobile ? 18 : isTablet ? 20 : 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View on Map',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: isMobile ? 14 : isTablet ? 16 : 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // About School
                          if (school['about'] != null)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About School',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    school['about'],
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : isTablet ? 15 : 16,
                                      color: const Color(0xFF5F6F81),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),
                          
                          // School Gallery
                          if (school['gallery'] != null && (school['gallery'] as List).isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'School Gallery',
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: isMobile ? 120 : 180,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (school['gallery'] as List).length,
                                      itemBuilder: (context, index) {
                                        final imageUrl = (school['gallery'] as List)[index].toString();
                                        return Container(
                                          width: isMobile ? 180 : 250,
                                          margin: const EdgeInsets.only(right: 12),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey[200],
                                                child: const Center(child: GlassLoader()),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          const SizedBox(height: 16),

                          // Call & WhatsApp Buttons
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _callNow,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE51515),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isMobile ? 14 : isTablet ? 16 : 18,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.call,
                                          color: Colors.white,
                                          size: isMobile ? 18 : isTablet ? 20 : 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Call',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: isMobile ? 14 : isTablet ? 16 : 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                SizedBox(width: isMobile ? 8 : isTablet ? 10 : 12),
                                
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _openWhatsApp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isMobile ? 14 : isTablet ? 16 : 18,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                          size: isMobile ? 18 : isTablet ? 20 : 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'WhatsApp',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: isMobile ? 14 : isTablet ? 16 : 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Rate & Review Section
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rate & Review',
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (!_isLoggedIn && !_isAuthChecking)
                                      TextButton(
                                        onPressed: _navigateToLogin,
                                        child: const Text(
                                          'Login to review',
                                          style: TextStyle(color: Color(0xFF0B5ED7)),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                if (_isAuthChecking)
                                  const Center(child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: GlassLoader(),
                                  ))
                                else if (!_isLoggedIn)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Login to share your experience',
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: _navigateToLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0B5ED7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text('Login to review'),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_hasUserReviewed)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline, color: Colors.orange[700]),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'You have already reviewed this school',
                                                style: TextStyle(
                                                  color: Colors.orange[700],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Each user can only post one review per school. Thank you for your feedback!',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else if (!_hasUserReviewed && _isLoggedIn) ...[
                                  Text(
                                    'Rate your experience',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        onPressed: _isSubmittingReview ? null : () => setState(() => _rating = index + 1),
                                        icon: Icon(
                                          index < _rating ? Icons.star : Icons.star_border,
                                          size: isTablet ? 36 : 32,
                                          color: const Color(0xFFFFD700),
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE0E7FF)),
                                    ),
                                    child: TextField(
                                      controller: _reviewController,
                                      maxLines: 4,
                                      minLines: 3,
                                      enabled: !_isSubmittingReview,
                                      decoration: InputDecoration(
                                        hintText: 'Share your experience...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: isTablet ? 16 : 14,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
                                      ),
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isSubmittingReview ? null : _submitReview,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0B5ED7),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 16 : 14,
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isSubmittingReview
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: GlassLoader(),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.send,
                                                  size: isTablet ? 20 : 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Submit Review',
                                                  style: TextStyle(
                                                    fontSize: isTablet ? 16 : 14,
                                                    fontWeight: FontWeight.w600,
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

                          const SizedBox(height: 16),

                          // User Reviews Section
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: EdgeInsets.all(cardPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'User Reviews (${_reviews.length})',
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (_averageRating > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF9E6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Color(0xFFFFB703)),
                                            const SizedBox(width: 4),
                                            Text(
                                              _averageRating.toStringAsFixed(1),
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                if (_reviews.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rate_review_outlined,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No reviews yet',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (_isLoggedIn && !_hasUserReviewed)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                'Be the first to review!',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ..._reviews.map((review) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: isMobile ? 10 : isTablet ? 12 : 14),
                                      padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 14 : 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  review['name'],
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 14 : isTablet ? 16 : 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF004780),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(5, (index) {
                                                  return Icon(
                                                    index < review['rating'] ? Icons.star : Icons.star_outline,
                                                    color: const Color(0xFFFFD700),
                                                    size: isMobile ? 14 : isTablet ? 16 : 18,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            review['comment'],
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : isTablet ? 15 : 16,
                                              color: const Color(0xFF5F6F81),
                                              height: 1.5,
                                            ),
                                          ),
                                          if (review['createdAt'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                _formatDate(review['createdAt']),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),

                          // Video Section with API videos
                          if (_youtubeUrls.isNotEmpty || !isTablet || isDesktop)
                            Container(
                              margin: EdgeInsets.only(
                                top: isMobile ? 32 : isTablet ? 40 : 48,
                                bottom: 0,
                              ),
                              width: double.infinity,
                              height: videoHeight,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                image: _youtubeUrls.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(_getVideoThumbnail(_youtubeUrls[_currentVideoIndex])),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      )
                                    : const DecorationImage(
                                        image: NetworkImage('https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (_youtubeUrls.length > 1)
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: _previousVideo,
                                              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Text(
                                              '${_currentVideoIndex + 1}/${_youtubeUrls.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: _nextVideo,
                                              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Footer(
              currentIndex: _footerIndex,
              onItemTapped: (index) {
                setState(() {
                  _footerIndex = index;
                });
                _handleFooterNavigation(index, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year(s) ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month(s) ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}