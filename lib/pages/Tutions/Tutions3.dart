// lib/pages/Tutions/Tutions3.dart
import 'package:flutter/material.dart';
import 'package:master/components/glass_loader.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/School/review_service.dart';
import '../../Api/baseurl.dart';
import '../../services/auth_token_manager.dart';

class Tution3Screen extends StatefulWidget {
  final String instituteName;
  final Map<String, dynamic>? instituteData;

  const Tution3Screen({
    super.key,
    this.instituteName = 'Elite Scholars Academy',
    this.instituteData,
  });

  @override
  State<Tution3Screen> createState() => _Tution3ScreenState();
}

class _Tution3ScreenState extends State<Tution3Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  int _currentVideoIndex = 0;
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  Timer? _adTimer;
  final PageController _adController = PageController();

  // Advertisement Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  bool _adsLoaded = false;
  bool _apiCallFailed = false;

  // Default ads (fallback if API fails)
  final List<String> defaultAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get ads => _adImages.isNotEmpty ? _adImages : defaultAds;

  // Reviews from API
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;

  bool _isLoading = false;
  bool _isSubmittingReview = false;

  // Authentication using AuthTokenManager
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  bool _isLoggedIn = false;
  int? _currentUserId;
  bool _hasUserReviewed = false;
  bool _isAuthChecking = true;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    _checkAuthStatus();
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for tuitionspage3...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=tuitionspage3'),
      );

      debugPrint('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('📦 API Response: $data');

        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          debugPrint('✅ API Data found');

          setState(() {
            // Parse images
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
              debugPrint('🖼️ Loaded ${_adImages.length} images from API');
            }

            // Parse youtube URLs
            if (apiData['youtube_urls'] != null &&
                apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
              debugPrint('🎥 Loaded ${_youtubeUrls.length} videos from API');
            }
            _adsLoaded = true;
            _apiCallFailed = false;
          });
        } else {
          debugPrint('⚠️ API returned success false or no data');
          setState(() {
            _adsLoaded = true;
            _apiCallFailed = true;
          });
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ Page "tuitionspage3" not found in backend (404)');
        debugPrint('💡 Please create this page in your advertisements table');
        setState(() {
          _adsLoaded = true;
          _apiCallFailed = true;
        });
        
        // Show a snackbar to inform about missing backend data (optional)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Advertisement page not configured in backend'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
        setState(() {
          _adsLoaded = true;
          _apiCallFailed = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      setState(() {
        _adsLoaded = true;
        _apiCallFailed = true;
      });
    } finally {
      debugPrint('✅ Using ${ads.length} images (${_adImages.isEmpty ? 'fallback' : 'API'})');
      // Start auto-scroll after ads are loaded
      _startAdAutoScroll();
    }
  }

  void _startAdAutoScroll() {
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAd + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _adController.animateToPage(
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

  Future<void> _loadReviews() async {
    if (widget.instituteData == null || widget.instituteData!['id'] == null)
      return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch reviews
      final reviews = await ReviewService().getEntityReviews(
        entityType: 'tuition',
        entityId: widget.instituteData!['id'],
      );

      // Fetch average rating
      final avgData = await ReviewService().getAverageRating(
        entityType: 'tuition',
        entityId: widget.instituteData!['id'],
      );

      // Format reviews
      final formattedReviews =
          reviews.map((r) => ReviewService().formatReview(r)).toList();

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
        userReviewed =
            formattedReviews.any((r) => r['userId'] == _currentUserId);
      }

      if (mounted) {
        setState(() {
          _reviews = formattedReviews;
          _averageRating = avgRating;
          _totalReviews = totalReviews;
          _hasUserReviewed = userReviewed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Error loading reviews: $e');
      }
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

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  // Simple URL launcher function
  void _launchURL(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would launch: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Action Methods
  void _openMap() {
    final link = widget.instituteData?['mapLink'] ??
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.instituteName)}';
    _launchURL(link);
  }

  void _callNow() {
    final number = widget.instituteData?['mobileNumber'] ?? '9876543210';
    _launchURL('tel:$number');
  }

  void _openWhatsApp() {
    final number = widget.instituteData?['whatsappNumber'] ?? '9876543210';
    _launchURL('https://wa.me/$number');
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
      _showDialog('Already Reviewed', 'You have already reviewed this tuition');
      return;
    }

    if (widget.instituteData == null || widget.instituteData!['id'] == null) {
      _showDialog('Error', 'Tuition information is missing');
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      await ReviewService().addReview(
        entityType: 'tuition',
        entityId: widget.instituteData!['id'],
        rating: _rating,
        review: _reviewController.text.trim(),
      );

      setState(() {
        _rating = 0;
        _reviewController.clear();
      });

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
        setState(() {
          _hasUserReviewed = true;
        });

        if (mounted) {
          _showDialog('Already Reviewed',
              'You have already submitted a review for this tuition. Each user can only post one review.');
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

  // Responsive functions
  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 64;
    if (screenWidth >= 768) return 58;
    return 52;
  }

  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 19;
    if (screenWidth >= 768) return 18;
    return 17;
  }

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 32;
    if (screenWidth >= 768) return 24;
    return 16;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double horizontalPadding = _getHorizontalPadding(context);
    final double adHeight = isTablet ? 200 : 180;
    final double cardPadding = isTablet ? 20 : 16;
    final double cardMargin = isTablet ? 16 : 12;
    final double videoHeight = isTablet ? 220 : 180;
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    double displayRating = _averageRating > 0
        ? _averageRating
        : (widget.instituteData?['rating'] ?? 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
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
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    height: _getHeaderHeight(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
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
                              'Institute Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _getTitleFontSize(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Top Ads - Always show (either API images or fallback)
                        SizedBox(
                          height: adHeight,
                          child: PageView.builder(
                            controller: _adController,
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              setState(() {
                                _activeAd = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                width: screenWidth,
                                color: const Color(0xFFF0F0F0),
                                child: Image.network(
                                  ads[index],
                                  width: screenWidth,
                                  height: adHeight,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: screenWidth,
                                      height: adHeight,
                                      color: const Color(0xFF0052A2),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color:
                                                  Colors.white.withOpacity(0.5),
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
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: screenWidth,
                                      height: adHeight,
                                      color: const Color(0xFF0052A2),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.white),
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(ads.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _activeAd == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: _activeAd == index
                                    ? const Color(0xFF0B5ED7)
                                    : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // Info message when using fallback (optional)
                        if (_apiCallFailed && _adImages.isEmpty)
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding, vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange[700], size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Using default advertisements',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Hero Card
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isTablet ? 20 : 16,
                            horizontalPadding,
                            0,
                          ),
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 20 : 16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.instituteName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 26 : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.instituteData?['shortDescription'] ??
                                    'Empowering Excellence since 2012',
                                style: TextStyle(
                                  color: const Color(0xFFDCE8FF),
                                  fontSize: isTablet ? 16 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.school,
                                text:
                                    (widget.instituteData?['category'] as List?)
                                            ?.join(', ') ??
                                        'All Standards',
                                isTablet: isTablet,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                icon: Icons.location_on,
                                text: widget.instituteData?['location'] ??
                                    'Location not available',
                                isTablet: isTablet,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: isTablet ? 20 : 16,
                                    color: const Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${displayRating.toStringAsFixed(1)} ${_totalReviews > 0 ? '($_totalReviews reviews)' : '(0 reviews)'}',
                                      style: TextStyle(
                                        color: const Color(0xFFE8F0FF),
                                        fontSize: isTablet ? 16 : 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Subjects
                        _buildSectionCard(
                          title: 'Subjects Offered',
                          isTablet: isTablet,
                          horizontalPadding: horizontalPadding,
                          marginTop: cardMargin,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (widget.instituteData?['subjectsOffered']
                                        as List? ??
                                    [])
                                .map((subject) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 16 : 12,
                                  vertical: isTablet ? 10 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  subject.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF0B5ED7),
                                    fontSize: isTablet ? 16 : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Teaching Mode
                        _buildSectionCard(
                          title: 'Teaching Mode',
                          isTablet: isTablet,
                          horizontalPadding: horizontalPadding,
                          marginTop: cardMargin,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: (widget.instituteData?['teachingMode']
                                          as List? ??
                                      [])
                                  .map((mode) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _buildModeCard(
                                    icon: mode
                                            .toString()
                                            .toLowerCase()
                                            .contains('online')
                                        ? Icons.videocam
                                        : Icons.business,
                                    title: mode.toString(),
                                    subtitle: mode
                                            .toString()
                                            .toLowerCase()
                                            .contains('online')
                                        ? 'Live/Recorded'
                                        : 'Classroom',
                                    isTablet: isTablet,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Map Button
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            cardMargin,
                            horizontalPadding,
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
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 18 : 14,
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: isTablet ? 22 : 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View on Map',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // About Institute
                        _buildSectionCard(
                          title: 'About Institute',
                          isTablet: isTablet,
                          horizontalPadding: horizontalPadding,
                          marginTop: cardMargin,
                          child: Text(
                            widget.instituteData?['about'] ??
                                'No description available for this institute.',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 13,
                              color: const Color(0xFF5F6F81),
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Gallery
                        if (widget.instituteData?['gallery'] != null &&
                            (widget.instituteData?['gallery'] as List)
                                .isNotEmpty)
                          _buildSectionCard(
                            title: 'Gallery',
                            isTablet: isTablet,
                            horizontalPadding: horizontalPadding,
                            marginTop: cardMargin,
                            child: SizedBox(
                              height: isTablet ? 180 : 130,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount:
                                    (widget.instituteData?['gallery'] as List)
                                        .length,
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      (widget.instituteData?['gallery']
                                              as List)[index]
                                          .toString();
                                  return Container(
                                    width: isTablet ? 240 : 180,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, e, s) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Rate & Review
                        _buildSectionCard(
                          title: 'Rate & Review',
                          isTablet: isTablet,
                          horizontalPadding: horizontalPadding,
                          marginTop: cardMargin,
                          child: Column(
                            children: [
                              if (_isAuthChecking)
                                const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: GlassLoader(size: 60),
                                ))
                              else if (!_isLoggedIn)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Login to share your experience',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _navigateToLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF0B5ED7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                          Icon(Icons.info_outline,
                                              color: Colors.orange[700]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'You have already reviewed this institute',
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
                                        'Each user can only post one review per institute. Thank you for your feedback!',
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
                                      onPressed: _isSubmittingReview
                                          ? null
                                          : () {
                                              setState(() {
                                                _rating = index + 1;
                                              });
                                            },
                                      icon: Icon(
                                        index < _rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: isTablet ? 36 : 32,
                                        color: const Color(0xFFFFD700),
                                      ),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE0E7FF)),
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
                                      contentPadding:
                                          EdgeInsets.all(isTablet ? 16 : 12),
                                    ),
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmittingReview
                                        ? null
                                        : _submitReview,
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
                                            child: GlassLoader(
                                              size: 20,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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

                        // Reviews List
                        _buildSectionCard(
                          title: 'Student Reviews (${_reviews.length})',
                          isTablet: isTablet,
                          horizontalPadding: horizontalPadding,
                          marginTop: cardMargin,
                          child: _isLoading
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: GlassLoader(size: 60),
                                ))
                              : _reviews.isEmpty
                                  ? Container(
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
                                            if (_isLoggedIn &&
                                                !_hasUserReviewed)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
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
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _reviews.length,
                                      itemBuilder: (context, index) {
                                        return _buildReviewCard(
                                            _reviews[index], isTablet);
                                      },
                                    ),
                        ),

                        // Call & WhatsApp
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            cardMargin,
                            horizontalPadding,
                            0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _callNow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53E3E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          isTablet ? 16 : 14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 14,
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.call,
                                        size: isTablet ? 22 : 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Call Now',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _openWhatsApp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          isTablet ? 16 : 14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 14,
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.message,
                                        size: isTablet ? 22 : 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'WhatsApp',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Video Section
                        if (_youtubeUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _youtubeUrls.length > 1 ? 'Videos' : 'Video',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                if (_youtubeUrls.length > 1)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _previousVideo,
                                        icon: const Icon(Icons.chevron_left,
                                            color: Color(0xFF0B5ED7)),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
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
                                        icon: const Icon(Icons.chevron_right,
                                            color: Color(0xFF0B5ED7)),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],

                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: double.infinity,
                          height: videoHeight,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            image: DecorationImage(
                              image: NetworkImage(
                                _youtubeUrls.isNotEmpty
                                    ? _getVideoThumbnail(
                                        _youtubeUrls[_currentVideoIndex])
                                    : 'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                              ),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: _previousVideo,
                                          icon: const Icon(Icons.chevron_left,
                                              color: Colors.white, size: 20),
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
                                          icon: const Icon(Icons.chevron_right,
                                              color: Colors.white, size: 20),
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

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                Footer(
                  currentIndex: _footerIndex,
                  onItemTapped: (index) {
                    setState(() {
                      _footerIndex = index;
                    });
                  },
                ),
              ],
            ),
            if (_isLoading)
              const GlassLoader(
                message: 'Loading institute details...',
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isTablet,
    Color iconColor = Colors.white,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 20 : 16,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFFE8F0FF),
              fontSize: isTablet ? 16 : 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required bool isTablet,
    required double horizontalPadding,
    required double marginTop,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        marginTop,
        horizontalPadding,
        0,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 22 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isTablet,
  }) {
    return Container(
      width: isTablet ? 180 : 150,
      padding: EdgeInsets.all(isTablet ? 20 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? 40 : 22,
            color: const Color(0xFF0B5ED7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isTablet ? 14 : 11,
              color: const Color(0xFF5F6F81),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
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
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B5ED7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    size: isTablet ? 18 : 14,
                    color: const Color(0xFFFFD700),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: isTablet ? 16 : 13,
              color: const Color(0xFF4B5563),
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
  }
}