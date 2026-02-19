// lib/pages/Extraskills/Extraskills4.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../services/auth_token_manager.dart';
import '../../Api/ExtraSkill/extra_skill_review_service.dart';
import '../../components/glass_loader.dart';

class Extraskills4Screen extends StatefulWidget {
  final Map<String, dynamic> institution;

  const Extraskills4Screen({
    super.key,
    required this.institution,
  });

  @override
  State<Extraskills4Screen> createState() => _Extraskills4ScreenState();
}

class _Extraskills4ScreenState extends State<Extraskills4Screen> {
  int _currentBannerIndex = 0;
  int _currentVideoIndex = 0;
  int _rating = 0;
  final PageController _bannerController = PageController();
  final TextEditingController _reviewController = TextEditingController();

  // Loading states
  bool _isLoadingAds = true;
  bool _isLoadingReviews = true;
  bool _isSubmittingReview = false;
  String? _errorMessage;

  // API Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];

  // Reviews from API
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;

  // Authentication
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  bool _isLoggedIn = false;
  int? _currentUserId;
  bool _hasUserReviewed = false;
  bool _isAuthChecking = true;

  final ExtraSkillReviewService _reviewService = ExtraSkillReviewService();

  // Default banner ads (fallback if API fails)
  final List<String> _defaultBannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadAdvertisements();
    _loadReviews();
    _startBannerAutoScroll();
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _currentUserId = null;
          _isAuthChecking = false;
        });
      }
    }
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for extraskillpage4...');

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage4'),
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
        } else {
          setState(() {
            _isLoadingAds = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAds = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading advertisements: $e');
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    final institutionId = widget.institution['id'];
    if (institutionId == null) {
      debugPrint('❌ No institution ID found');
      setState(() {
        _isLoadingReviews = false;
      });
      return;
    }

    debugPrint('🔄 Loading reviews for institution ID: $institutionId');
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // Fetch reviews
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-reviews/$institutionId'),
      );

      debugPrint('📡 Reviews API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        
        debugPrint('✅ Response is a List with ${responseData.length} items');
        
        // Format each review using the userName from API
        final formattedReviews = responseData.map((review) {
          return {
            'id': review['id'] ?? 0,
            'name': review['userName'] ?? 'User ${review['userId']}', // Now gets actual username from API!
            'rating': review['rating'] ?? 0,
            'comment': review['review'] ?? review['comment'] ?? '',
            'userId': review['userId'] ?? 0,
            'createdAt': review['createdAt'] ?? '',
          };
        }).toList();
        
        debugPrint('✅ Formatted ${formattedReviews.length} reviews with user names');

        // Try to fetch average rating (if endpoint exists)
        double avgRating = 0.0;
        int totalReviews = formattedReviews.length;
        
        try {
          final avgResponse = await http.get(
            Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-reviews/$institutionId/average'),
          );

          if (avgResponse.statusCode == 200) {
            final avgData = json.decode(avgResponse.body);
            
            if (avgData is Map<String, dynamic>) {
              if (avgData['averageRating'] != null) {
                avgRating = (avgData['averageRating'] as num).toDouble();
              }
              if (avgData['totalReviews'] != null) {
                totalReviews = avgData['totalReviews'] as int;
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Could not fetch average rating, calculating from reviews');
          // Calculate average from reviews
          if (formattedReviews.isNotEmpty) {
            final sum = formattedReviews.fold<int>(
              0, 
              (sum, review) => sum + (review['rating'] as int)
            );
            avgRating = sum / formattedReviews.length;
          }
        }

        // Check if current user has reviewed
        bool userReviewed = false;
        if (_currentUserId != null) {
          userReviewed = formattedReviews.any((r) => r['userId'] == _currentUserId);
          if (userReviewed) {
            debugPrint('✅ Current user (ID: $_currentUserId) has already reviewed');
          }
        }

        if (mounted) {
          setState(() {
            _reviews = formattedReviews;
            _averageRating = avgRating;
            _totalReviews = totalReviews;
            _hasUserReviewed = userReviewed;
            _isLoadingReviews = false;
          });
          
          // Print to verify names are showing
          for (var review in _reviews) {
            debugPrint('📝 Review by: ${review['name']}');
          }
        }
      } else {
        debugPrint('❌ Failed to load reviews: ${response.statusCode}');
        setState(() {
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _errorMessage = 'Failed to load reviews';
        });
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
      _showDialog(
          'Already Reviewed', 'You have already reviewed this institution');
      return;
    }

    final institutionId = widget.institution['id'];
    if (institutionId == null) {
      _showDialog('Error', 'Institution information is missing');
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      await _reviewService.addReview(
        institutionId: institutionId,
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
              'You have already submitted a review for this institution. Each user can only post one review.');
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

  @override
  void dispose() {
    _bannerController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= bannerAds.length) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
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

  void _handleWhatsApp() {
    final whatsapp = widget.institution['whatsappNumber'] ?? '+123456789';
    _showUrlDialog('WhatsApp', 'Would open WhatsApp to: $whatsapp');
  }

  void _handleCall() {
    final phone = widget.institution['mobileNumber'] ?? '+123456789';
    _showUrlDialog('Call', 'Would call: $phone');
  }

  void _handleWebsite() {
    final website = widget.institution['websiteUrl'] ?? 'www.example.com';
    _showUrlDialog('Website', 'Would open: $website');
  }

  void _handleVideo(String url) {
    _showUrlDialog('External Link', 'Would you like to open the video?');
  }

  void _showUrlDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening...')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  String _getLocationString() {
    List<String> parts = [];
    if (widget.institution['area'] != null &&
        widget.institution['area'].toString().isNotEmpty) {
      parts.add(widget.institution['area']);
    }
    if (widget.institution['district'] != null &&
        widget.institution['district'].toString().isNotEmpty) {
      parts.add(widget.institution['district']);
    }
    if (widget.institution['state'] != null &&
        widget.institution['state'].toString().isNotEmpty) {
      parts.add(widget.institution['state']);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Location not specified';
  }

  String _getWebsiteUrl() {
    final url = widget.institution['websiteUrl'];
    if (url != null && url.toString().isNotEmpty) {
      String urlStr = url.toString();
      if (!urlStr.startsWith('http')) {
        return urlStr;
      }
      return urlStr.replaceAll('https://', '').replaceAll('http://', '');
    }
    return 'Not available';
  }

  String _getVideoThumbnail(String url) {
    if (url.contains('youtube.com/embed/')) {
      final videoId = url.split('/').last;
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return url;
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
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    double responsiveValue(double mobile, double tablet, double desktop) {
      if (isDesktop) return desktop;
      if (isTablet) return tablet;
      return mobile;
    }

    final double bannerHeight = responsiveValue(180, 240, 280);
    final double videoHeight = responsiveValue(200, 280, 320);
    final double heroCardHeight = responsiveValue(240, 260, 280);
    final double galleryImageSize = responsiveValue(100, 130, 160);
    final double horizontalPadding = responsiveValue(16, 20, 24);
    final double cardPadding = responsiveValue(16, 20, 24);
    final double cardRadius = responsiveValue(16, 18, 20);
    final double bodyFontSize = responsiveValue(14, 15, 16);
    final double smallFontSize = responsiveValue(12, 13, 14);

    final String institutionName =
        widget.institution['name'] ?? 'Unknown Institution';
    final String location = _getLocationString();
    final String about =
        widget.institution['about'] ?? 'No description available.';
    final List<String> weOffer = widget.institution['weOffer'] is List
        ? List<String>.from(widget.institution['weOffer'])
        : ['Dance', 'Zumba', 'Fitness'];
    final String websiteUrl = _getWebsiteUrl();
    final List<String> gallery = widget.institution['gallery'] is List
        ? List<String>.from(widget.institution['gallery'])
        : [];
    final String aboutTrainers =
        widget.institution['aboutOurTrainers'] ?? 'No information available.';
    final String imageUrl = widget.institution['image'];

    double displayRating = _averageRating > 0 ? _averageRating : 4.5;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0052A2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: responsiveValue(52, 64, 72),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: responsiveValue(24, 26, 28),
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Institution Details',
                          style: TextStyle(
                            fontSize: responsiveValue(18, 20, 22),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Banner Carousel
                      SizedBox(
                        height: bannerHeight,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: bannerAds.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              width: double.infinity,
                              child: Image.network(
                                bannerAds[index],
                                width: double.infinity,
                                height: bannerHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: bannerHeight,
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
                                    width: double.infinity,
                                    height: bannerHeight,
                                    color: const Color(0xFF0052A2),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
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
                      SizedBox(height: responsiveValue(8, 10, 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: bannerAds.asMap().entries.map((entry) {
                          return Container(
                            width: responsiveValue(6, 7, 8),
                            height: responsiveValue(6, 7, 8),
                            margin: EdgeInsets.symmetric(
                              horizontal: responsiveValue(3, 4, 5),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentBannerIndex == entry.key
                                  ? const Color(0xFF0B5ED7)
                                  : Colors.grey[300],
                            ),
                          );
                        }).toList(),
                      ),

                      // Main Content
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            // Hero Card
                            Container(
                              width: double.infinity,
                              height: heroCardHeight,
                              margin: EdgeInsets.only(
                                top: responsiveValue(16, 20, 24),
                              ),
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C73AC),
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: responsiveValue(90, 110, 130),
                                    height: responsiveValue(90, 110, 130),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      image: imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                              onError:
                                                  (exception, stackTrace) {},
                                            )
                                          : null,
                                    ),
                                    child: imageUrl == null
                                        ? Icon(
                                            Icons.business,
                                            size: 60,
                                            color: const Color(0xFF4C73AC),
                                          )
                                        : null,
                                  ),

                                  SizedBox(height: responsiveValue(12, 14, 16)),

                                  Text(
                                    institutionName,
                                    style: TextStyle(
                                      fontSize: responsiveValue(20, 22, 24),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: responsiveValue(4, 6, 8)),

                                  // Rating with review count
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 20,
                                        color: Color(0xFFFFD700),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        displayRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFF9E6),
                                        ),
                                      ),
                                      if (_totalReviews > 0) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '($_totalReviews)',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFE8F0FF),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  SizedBox(height: responsiveValue(8, 10, 12)),

                                  // Location
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: responsiveValue(16, 18, 20),
                                        color: const Color(0xFFE8F0FF),
                                      ),
                                      SizedBox(
                                          width: responsiveValue(6, 8, 10)),
                                      Flexible(
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize:
                                                responsiveValue(12, 13, 14),
                                            color: const Color(0xFFE8F0FF),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // About Institution
                            _buildSectionCard(
                              title: 'About Institution',
                              content: Text(
                                about,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: const Color(0xFF5F6F81),
                                  height: 1.5,
                                ),
                              ),
                              padding: cardPadding,
                              radius: cardRadius,
                              topMargin: responsiveValue(16, 20, 24),
                            ),

                            // We Offer
                            _buildSectionCard(
                              title: 'We Offer',
                              content: Wrap(
                                spacing: responsiveValue(8, 10, 12),
                                runSpacing: responsiveValue(8, 10, 12),
                                children: weOffer.map((offer) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: responsiveValue(12, 14, 16),
                                      vertical: responsiveValue(6, 8, 10),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      offer,
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0B5ED7),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              padding: cardPadding,
                              radius: cardRadius,
                            ),

                            // Website
                            if (widget.institution['websiteUrl'] != null)
                              _buildSectionCard(
                                title: 'Website',
                                content: GestureDetector(
                                  onTap: _handleWebsite,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        size: responsiveValue(16, 18, 20),
                                        color: const Color(0xFF0B5ED7),
                                      ),
                                      SizedBox(
                                          width: responsiveValue(8, 10, 12)),
                                      Expanded(
                                        child: Text(
                                          websiteUrl,
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            color: const Color(0xFF0B5ED7),
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                padding: cardPadding,
                                radius: cardRadius,
                              ),

                            // Gallery
                            if (gallery.isNotEmpty)
                              _buildSectionCard(
                                title: 'Gallery',
                                content: SizedBox(
                                  height: galleryImageSize,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: gallery.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = gallery[index];
                                      String fullImageUrl = imageUrl;
                                      if (!imageUrl.startsWith('http')) {
                                        fullImageUrl =
                                            '${BaseUrl.baseUrl}/$imageUrl';
                                      }

                                      return Container(
                                        width: galleryImageSize,
                                        height: galleryImageSize,
                                        margin: EdgeInsets.only(
                                          right: responsiveValue(10, 14, 18),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: const Color(0xFFE8F0FF),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(fullImageUrl),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {},
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          ),
                                          child: const Icon(
                                            Icons.photo,
                                            size: 40,
                                            color: Color(0xFF4C73AC),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                padding: cardPadding,
                                radius: cardRadius,
                              ),

                            // About Our Trainers
                            _buildSectionCard(
                              title: 'About Our Trainers',
                              content: Text(
                                aboutTrainers,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: const Color(0xFF5F6F81),
                                  height: 1.5,
                                ),
                              ),
                              padding: cardPadding,
                              radius: cardRadius,
                            ),

                            // Rate & Review Section
                            _buildSectionCard(
                              title: 'Rate & Review',
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox.shrink(),
                                      if (!_isLoggedIn && !_isAuthChecking)
                                        TextButton(
                                          onPressed: _navigateToLogin,
                                          child: const Text(
                                            'Login to review',
                                            style: TextStyle(
                                                color: Color(0xFF0B5ED7)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (_isAuthChecking)
                                    const Center(
                                        child: Padding(
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
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
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
                                            child:
                                                const Text('Login to review'),
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
                                                  'You have already reviewed this institution',
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
                                            'Each user can only post one review per institution. Thank you for your feedback!',
                                            style: TextStyle(
                                              color: Colors.orange[700],
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (!_hasUserReviewed &&
                                      _isLoggedIn) ...[
                                    Text(
                                      'Rate your experience',
                                      style: TextStyle(
                                        fontSize: responsiveValue(14, 15, 16),
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
                                            size: responsiveValue(32, 34, 36),
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
                                            fontSize:
                                                responsiveValue(14, 15, 16),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(
                                              responsiveValue(12, 14, 16)),
                                        ),
                                        style: TextStyle(
                                          fontSize: responsiveValue(14, 15, 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
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
                                                responsiveValue(14, 15, 16),
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.send,
                                                    size: responsiveValue(
                                                        18, 19, 20),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Submit Review',
                                                    style: TextStyle(
                                                      fontSize: responsiveValue(
                                                          14, 15, 16),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              padding: cardPadding,
                              radius: cardRadius,
                            ),

                            // Reviews List Section
                            _buildSectionCard(
                              title: 'User Reviews (${_reviews.length})',
                              content: _isLoadingReviews
                                  ? const Center(
                                      child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: GlassLoader(),
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
                                                    padding:
                                                        const EdgeInsets.only(
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
                                      : Column(
                                          children: _reviews.map((review) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                  bottom: responsiveValue(
                                                      10, 12, 14)),
                                              padding: EdgeInsets.all(
                                                  responsiveValue(12, 14, 16)),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFF),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          review['name'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                responsiveValue(
                                                                    14, 15, 16),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: const Color(
                                                                0xFF004780),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: List.generate(
                                                            5, (index) {
                                                          return Icon(
                                                            index <
                                                                    review[
                                                                        'rating']
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_outline,
                                                            color: const Color(
                                                                0xFFFFD700),
                                                            size:
                                                                responsiveValue(
                                                                    14, 15, 16),
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    review['comment'],
                                                    style: TextStyle(
                                                      fontSize: responsiveValue(
                                                          13, 14, 15),
                                                      color: const Color(
                                                          0xFF5F6F81),
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  if (review['createdAt'] !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        _formatDate(review[
                                                            'createdAt']),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                              padding: cardPadding,
                              radius: cardRadius,
                            ),

                            // Call & WhatsApp Buttons
                            Container(
                              margin: EdgeInsets.only(
                                top: responsiveValue(16, 20, 24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleCall,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE51515),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: responsiveValue(14, 16, 18),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            size: responsiveValue(18, 20, 22),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Call',
                                            style: TextStyle(
                                              fontSize: bodyFontSize,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: responsiveValue(8, 10, 12)),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleWhatsApp,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF25D366),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: responsiveValue(14, 16, 18),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat,
                                            size: responsiveValue(18, 20, 22),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'WhatsApp',
                                            style: TextStyle(
                                              fontSize: bodyFontSize,
                                              fontWeight: FontWeight.w700,
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
                              if (_youtubeUrls.length > 1)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: responsiveValue(20, 24, 28)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _previousVideo,
                                        icon: const Icon(Icons.chevron_left,
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
                                        icon: const Icon(Icons.chevron_right,
                                            color: Color(0xFF0B5ED7)),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                width: double.infinity,
                                height: videoHeight,
                                margin: EdgeInsets.only(
                                  top: responsiveValue(12, 16, 20),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: videoHeight,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              _getVideoThumbnail(_youtubeUrls[
                                                  _currentVideoIndex]),
                                            ),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {},
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: videoHeight,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () => _handleVideo(
                                                _youtubeUrls[
                                                    _currentVideoIndex]),
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
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
                    ],
                  ),
                ),

                // Loading overlay for ads
                if (_isLoadingAds)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: GlassLoader(
                        message: 'Loading...',
                        size: 80,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required double padding,
    required double radius,
    double topMargin = 0,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: topMargin,
        bottom: padding,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF004780),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}