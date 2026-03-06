// lib/pages/Course/Course4.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';
import '../../api/baseurl.dart';
import '../../services/auth_token_manager.dart';
import '../../services/user_service.dart';

class Course4Screen extends StatefulWidget {
  final Map<String, dynamic>? provider;

  const Course4Screen({
    super.key,
    this.provider,
  });

  @override
  State<Course4Screen> createState() => _Course4ScreenState();
}

class _Course4ScreenState extends State<Course4Screen> {
  int _activeAd = 0;
  int _rating = 0;
  final PageController _adController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  Timer? _adTimer;

  // Services
  final AuthTokenManager _authManager = AuthTokenManager.instance;
  final UserService _userService = UserService();

  // Loading states
  bool _isLoadingAds = true;
  bool _isSubmittingReview = false;
  bool _isLoadingReviews = true;
  String? _reviewsError;

  // Authentication
  bool _isLoggedIn = false;
  int? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserName;
  bool _hasUserReviewed = false;
  bool _isAuthChecking = true;

  // Reviews from API and local
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;

  // Ads and Videos
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;
  bool _apiCallFailed = false;

  // Default Banner Ads (fallback)
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get bannerAds =>
      _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadAdvertisements();
    _loadLocalReviews();
    _fetchReviews();
    _startAdTimer();
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _isAuthChecking = true);

    try {
      final hasToken = await _authManager.hasToken();
      final userData = await _authManager.getUserData();
      final userEmail = await _authManager.getEmail();
      final userName = await _authManager.getUsername();

      if (mounted) {
        setState(() {
          _isLoggedIn = hasToken;
          _currentUserId = userData != null ? userData['id'] as int? : null;
          _currentUserEmail = userEmail;
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
          _currentUserEmail = null;
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

    final userReviewExists = _reviews.any((review) {
      final reviewUserId = review['userId'];
      return reviewUserId == _currentUserId;
    });

    setState(() => _hasUserReviewed = userReviewExists);
  }

  Future<void> _loadLocalReviews() async {
    final providerId = _getProviderId();
    if (providerId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reviewsJson = prefs.getString('reviews_provider_$providerId');
      
      if (reviewsJson != null) {
        final List<dynamic> decoded = jsonDecode(reviewsJson);
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(decoded);
          _totalReviews = _reviews.length;
          _calculateAverageRating();
        });
        
        if (_currentUserId != null) {
          _checkIfUserReviewed();
        }
      }
    } catch (e) {
      debugPrint('Error loading local reviews: $e');
    }
  }

  Future<void> _saveLocalReviews() async {
    final providerId = _getProviderId();
    if (providerId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String reviewsJson = jsonEncode(_reviews);
      await prefs.setString('reviews_provider_$providerId', reviewsJson);
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
      if (review['rating'] != null) {
        if (review['rating'] is int) {
          sum += (review['rating'] as int).toDouble();
        } else if (review['rating'] is double) {
          sum += review['rating'] as double;
        } else if (review['rating'] is String) {
          double? value = double.tryParse(review['rating'].toString());
          if (value != null) {
            sum += value;
          }
        }
      }
    }
    _averageRating = _reviews.isEmpty ? 0.0 : sum / _reviews.length;
  }

  Future<void> _fetchReviews() async {
    final providerId = _getProviderId();
    if (providerId == null) {
      setState(() => _isLoadingReviews = false);
      return;
    }

    setState(() => _isLoadingReviews = true);

    try {
      final token = await _authManager.getToken();
      
      // CORRECT URL: Use path parameter instead of query parameter
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/course-provider-reviews/$providerId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Reviews API Response Status: ${response.statusCode}');
      debugPrint('📡 Reviews API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Handle the response format: { "totalReviews": 2, "reviews": [...] }
        if (jsonResponse.containsKey('reviews') && jsonResponse['reviews'] is List) {
          final List<dynamic> reviewsList = jsonResponse['reviews'];
          final int totalReviews = jsonResponse['totalReviews'] ?? 0;
          
          debugPrint('📡 Found reviews list with ${reviewsList.length} items');
          
          if (reviewsList.isEmpty) {
            debugPrint('📡 No reviews found');
            setState(() {
              _reviews = [];
              _totalReviews = 0;
              _calculateAverageRating();
              _isLoadingReviews = false;
            });
            return;
          }
          
          // Collect all user IDs to fetch names (though usernames are already in response)
          final List<int> userIds = [];
          for (var review in reviewsList) {
            if (review is Map<String, dynamic>) {
              if (review.containsKey('userId') && review['userId'] != null) {
                if (review['userId'] is int) {
                  userIds.add(review['userId'] as int);
                } else if (review['userId'] is String) {
                  int? id = int.tryParse(review['userId'].toString());
                  if (id != null) userIds.add(id);
                }
              }
            }
          }
          
          debugPrint('📡 Found ${userIds.length} user IDs');
          
          // Format each review (usernames are already in the response)
          final formattedReviews = <Map<String, dynamic>>[];
          for (var review in reviewsList) {
            if (review is Map<String, dynamic>) {
              int? userId;
              if (review.containsKey('userId')) {
                if (review['userId'] is int) {
                  userId = review['userId'] as int;
                } else if (review['userId'] is String) {
                  userId = int.tryParse(review['userId'].toString());
                }
              }
              
              formattedReviews.add({
                'id': review['id'] ?? 0,
                'userId': userId,
                'userName': review['username'] ?? 'Anonymous',
                'rating': review['rating'] ?? 0,
                'review': review['review'] ?? '',
                'createdAt': review['createdAt'] ?? DateTime.now().toIso8601String(),
              });
            }
          }

          debugPrint('📡 Formatted ${formattedReviews.length} reviews');
          for (var r in formattedReviews) {
            debugPrint('📝 Review: ${r['userName']} - ${r['rating']} stars - ${r['review']}');
          }

          setState(() {
            _reviews = formattedReviews;
            _totalReviews = totalReviews;
            _calculateAverageRating();
            _isLoadingReviews = false;
          });
          
          // Save to local storage
          await _saveLocalReviews();
          
          if (_currentUserId != null) {
            _checkIfUserReviewed();
          }
        } else {
          debugPrint('📡 Unexpected response format');
          setState(() => _isLoadingReviews = false);
        }
      } else if (response.statusCode == 404) {
        debugPrint('📡 Reviews endpoint not found (404)');
        setState(() => _isLoadingReviews = false);
      } else {
        debugPrint('📡 Failed to load reviews: ${response.statusCode}');
        setState(() {
          _reviewsError = 'Failed to load reviews: ${response.statusCode}';
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
      _showDialog('Already Reviewed', 'You have already reviewed this provider');
      return;
    }

    final providerId = _getProviderId();
    if (providerId == null) {
      _showDialog('Error', 'Provider information is missing');
      return;
    }

    setState(() => _isSubmittingReview = true);

    try {
      final token = await _authManager.getToken();
      final userEmail = await _authManager.getEmail();

      if (token == null) {
        _showDialog('Login Required', 'Please login to submit a review');
        setState(() => _isSubmittingReview = false);
        return;
      }

      final newReview = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'userId': _currentUserId,
        'userName': _currentUserName ?? 'Anonymous User',
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      try {
        final reviewData = {
          'courseProviderId': providerId,
          'rating': _rating,
          'review': _reviewController.text.trim(),
        };

        final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/api/course-provider-reviews'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(reviewData),
        );

        debugPrint('📡 Submit Review Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
            if (jsonResponse.containsKey('id')) {
              newReview['id'] = jsonResponse['id'];
            }
          } catch (e) {
            // Ignore parsing error
          }
        } else if (response.statusCode == 409 || response.statusCode == 400) {
          setState(() {
            _hasUserReviewed = true;
            _isSubmittingReview = false;
          });
          _showDialog('Already Reviewed', 
              'You have already submitted a review for this provider. Each user can only post one review.');
          return;
        } else {
          debugPrint('⚠️ API submission failed with status ${response.statusCode}, saving locally only');
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
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      setState(() => _isSubmittingReview = false);
      _showDialog('Error', e.toString().replaceFirst('Exception: ', ''));
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
    Navigator.pushNamed(context, '/auth').then((_) {
      _checkAuthStatus();
      _loadLocalReviews();
      _fetchReviews();
    });
  }

  Future<void> _loadAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=coursepage4'),
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
            _apiCallFailed = false;
          });
        } else {
          setState(() {
            _isLoadingAds = false;
            _apiCallFailed = true;
          });
        }
      } else {
        setState(() {
          _isLoadingAds = false;
          _apiCallFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAds = false;
        _apiCallFailed = true;
      });
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

  void _startAdTimer() {
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

  int? _getProviderId() {
    final id = widget.provider?['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  String _getProviderName() {
    final name = widget.provider?['name'];
    return name?.toString() ?? 'AK Technologies';
  }

  String? _getProviderImage() {
    final image = widget.provider?['image'];
    return image?.toString();
  }

  String _getProviderShortDescription() {
    final desc = widget.provider?['shortDescription'];
    return desc?.toString() ?? 'IT Training & Placement Support';
  }

  String _getProviderAbout() {
    final about = widget.provider?['about'];
    return about?.toString() ?? 
        'Founded in 2015, this institute focuses on IT training and placement support. '
        'The institute offers technical courses including Python, Machine Learning, and live project training.';
  }

  double _getProviderRating() {
    final rating = widget.provider?['rating'];
    if (rating == null) return 4.5;
    if (rating is num) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 4.5;
    return 4.5;
  }

  String _getProviderLocation() {
    final parts = <String>[];
    
    final area = widget.provider?['area'];
    if (area != null && area.toString().isNotEmpty) {
      parts.add(area.toString());
    }
    
    final district = widget.provider?['district'];
    if (district != null && district.toString().isNotEmpty) {
      parts.add(district.toString());
    }
    
    final state = widget.provider?['state'];
    if (state != null && state.toString().isNotEmpty) {
      parts.add(state.toString());
    }
    
    return parts.isNotEmpty ? parts.join(' · ') : 'Location not specified';
  }

  String? _getProviderWebsite() {
    final website = widget.provider?['websiteUrl'];
    return website?.toString();
  }

  List<dynamic> _getCoursesOffered() {
    final courses = widget.provider?['coursesOffered'];
    if (courses is List) {
      return courses;
    }
    return [];
  }

  List<dynamic> _getTeachingModes() {
    final modes = widget.provider?['teachingMode'];
    if (modes is List) {
      return modes;
    }
    return [];
  }

  String _getProviderBenefits() {
    final benefits = widget.provider?['benefits'];
    return benefits?.toString() ?? '• Career growth\n• Industry-ready skills\n• Flexible learning';
  }

  String _getProviderMobile() {
    final mobile = widget.provider?['mobileNumber'];
    return mobile?.toString() ?? '9876543210';
  }

  String _getProviderWhatsapp() {
    final whatsapp = widget.provider?['whatsappNumber'];
    return whatsapp?.toString() ?? '9876543210';
  }

  List<dynamic> _getGallery() {
    final gallery = widget.provider?['gallery'];
    if (gallery is List) {
      return gallery;
    }
    return [];
  }

  String? _getMapLink() {
    final mapLink = widget.provider?['mapLink'];
    return mapLink?.toString();
  }

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link'),
        content: Text('Would you like to open: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showPhoneDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call'),
        content: Text('Would you like to call: $phoneNumber'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling: $phoneNumber')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showGalleryDialog() {
    final gallery = _getGallery();
    if (gallery.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              AppBar(
                title: const Text('Gallery'),
                backgroundColor: const Color(0xFF0052A2),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: gallery.length,
                  itemBuilder: (context, index) {
                    final imageUrl = gallery[index].toString();
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showFullImageDialog(imageUrl);
                      },
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Failed to load image'),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
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

  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2;
    if (screenWidth >= 768) return size * 1.1;
    return size;
  }

  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop;
    if (screenWidth >= 768) return tablet;
    return mobile;
  }

  Widget _buildStarRating(
      int rating, int activeStars, double size, Function(int)? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(rating, (index) {
        return GestureDetector(
          onTap: onTap != null ? () => onTap(index + 1) : null,
          child: Icon(
            index < activeStars ? Icons.star : Icons.star_outline,
            size: size,
            color: const Color(0xFFFFD700),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(200, 300, 300);
    final double videoHeight = _responsiveValue(250, 320, 400);
    final double cardPadding = _responsiveValue(16, 20, 24);
    final double cardRadius = _responsiveValue(16, 18, 20);
    final double bodyFontSize = _responsiveValue(14, 15, 16);
    final double smallFontSize = _responsiveValue(12, 13, 14);

    final String providerName = _getProviderName();
    final String? providerImage = _getProviderImage();
    final String providerShortDesc = _getProviderShortDescription();
    final String providerAbout = _getProviderAbout();
    final double providerRating = _getProviderRating();
    final String providerLocation = _getProviderLocation();
    final String? providerWebsite = _getProviderWebsite();
    final List<dynamic> coursesOffered = _getCoursesOffered();
    final List<dynamic> teachingModes = _getTeachingModes();
    final String providerBenefits = _getProviderBenefits();
    final String providerMobile = _getProviderMobile();
    final String providerWhatsapp = _getProviderWhatsapp();
    final List<dynamic> gallery = _getGallery();
    final String? mapLink = _getMapLink();

    double displayRating = _averageRating > 0 ? _averageRating : providerRating;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0052A2),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: _scale(24),
          ),
        ),
        title: Text(
          'Course Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.15),
        actions: [
          if (gallery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white),
              onPressed: _showGalleryDialog,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Banner Carousel
                  Container(
                    margin: EdgeInsets.only(
                      top: isDesktop ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: isDesktop
                          ? BorderRadius.circular(12)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: isDesktop
                          ? BorderRadius.circular(12)
                          : BorderRadius.zero,
                      child: SizedBox(
                        height: bannerHeight,
                        child: PageView.builder(
                          controller: _adController,
                          itemCount: bannerAds.length,
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
                                bannerAds[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF0B5ED7)),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 60,
                                          color: const Color(0xFF0B5ED7),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Advertisement ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF0B5ED7),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Dots Indicator
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(bannerAds.length, (index) {
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

                  // Fallback banner message
                  if (_adImages.isEmpty && !_isLoadingAds && _apiCallFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Using default banners',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Hero Card
                  Container(
                    margin: EdgeInsets.all(horizontalPadding),
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C73AC),
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo/Image
                        Container(
                          width: _responsiveValue(80, 100, 120),
                          height: _responsiveValue(80, 100, 120),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_scale(8)),
                            image: providerImage != null && providerImage.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(providerImage),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (providerImage == null || providerImage.isEmpty)
                              ? Center(
                                  child: Text(
                                    providerName.isNotEmpty ? providerName[0] : '?',
                                    style: TextStyle(
                                      fontSize: _scale(24),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0175D3),
                                    ),
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: 12),

                        // Provider Name
                        Text(
                          providerName,
                          style: TextStyle(
                            fontSize: _responsiveValue(18, 22, 26),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        // Short Description
                        Text(
                          providerShortDesc,
                          style: TextStyle(
                            fontSize: _responsiveValue(12, 14, 16),
                            color: const Color(0xFFDCE8FF),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Rating with review count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFFB703),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              displayRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_totalReviews > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($_totalReviews)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE8F0FF),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFFE8F0FF),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                providerLocation,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE8F0FF),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Website
                        if (providerWebsite != null && providerWebsite.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showUrlDialog(providerWebsite),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.language_outlined,
                                  size: 14,
                                  color: Color(0xFFE8F0FF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  providerWebsite.replaceAll('https://', '').replaceAll('http://', ''),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE8F0FF),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // About Institute
                  _buildSectionCard(
                    title: 'About Institute',
                    content: Text(
                      providerAbout,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        color: const Color(0xFF5F6F81),
                        height: 1.6,
                      ),
                    ),
                    padding: cardPadding,
                    radius: cardRadius,
                  ),

                  // Courses Offered
                  if (coursesOffered.isNotEmpty)
                    _buildSectionCard(
                      title: 'Courses Offered',
                      content: Wrap(
                        spacing: _responsiveValue(8, 10, 12),
                        runSpacing: _responsiveValue(8, 10, 12),
                        children: coursesOffered.map((course) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _responsiveValue(12, 14, 16),
                              vertical: _responsiveValue(6, 8, 10),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(_scale(10)),
                            ),
                            child: Text(
                              course.toString(),
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

                  // Teaching Mode
                  if (teachingModes.isNotEmpty)
                    _buildSectionCard(
                      title: 'Teaching Mode',
                      content: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: isMobile
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceBetween,
                            children: teachingModes.map((mode) {
                              final String modeStr = mode.toString();
                              final bool isOnline = modeStr.toLowerCase().contains('online');
                              return Expanded(
                                child: _buildModeCard(
                                  icon: isOnline ? Icons.videocam_outlined : Icons.business_outlined,
                                  title: modeStr,
                                  subtitle: isOnline ? 'Live Sessions' : 'Classroom Training',
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      padding: cardPadding,
                      radius: cardRadius,
                    ),

                  // Benefits
                  _buildSectionCard(
                    title: 'Benefits',
                    content: Text(
                      providerBenefits,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        color: const Color(0xFF5F6F81),
                        height: 2.0,
                      ),
                    ),
                    padding: cardPadding,
                    radius: cardRadius,
                  ),

                  // Map Link
                  if (mapLink != null && mapLink.isNotEmpty)
                    _buildSectionCard(
                      title: 'Location Map',
                      content: GestureDetector(
                        onTap: () => _showUrlDialog(mapLink),
                        child: Container(
                          padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(_scale(10)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.map, color: Color(0xFF0B5ED7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'View on Google Maps',
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    color: const Color(0xFF0B5ED7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF0B5ED7)),
                            ],
                          ),
                        ),
                      ),
                      padding: cardPadding,
                      radius: cardRadius,
                    ),

                  // Call & WhatsApp Buttons
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: _responsiveValue(16, 20, 24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showPhoneDialog(providerMobile),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe51515),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: _responsiveValue(14, 16, 18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_scale(14)),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFFe51515).withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.call),
                                SizedBox(width: _scale(8)),
                                Text(
                                  'Call Now',
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: _responsiveValue(12, 16, 20)),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _showUrlDialog('https://wa.me/${providerWhatsapp.replaceAll('+', '')}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: _responsiveValue(14, 16, 18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_scale(14)),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat),
                                SizedBox(width: _scale(8)),
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

                  // Rate & Review Section
                  _buildSectionCard(
                    title: 'Rate & Review',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox.shrink(),
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
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: GlassLoader(),
                            ),
                          )
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
                                        'You have already reviewed this provider',
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
                                  'Each user can only post one review per provider. Thank you for your feedback!',
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
                              fontSize: bodyFontSize,
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
                                    : () => setState(() => _rating = index + 1),
                                icon: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: _responsiveValue(32, 34, 36),
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
                                  fontSize: bodyFontSize,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
                              ),
                              style: TextStyle(fontSize: bodyFontSize),
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
                                  vertical: _responsiveValue(14, 15, 16),
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
                                          size: _responsiveValue(18, 19, 20),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Submit Review',
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
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
                    padding: cardPadding,
                    radius: cardRadius,
                  ),

                  // Student Reviews
                  _buildSectionCard(
                    title: 'Student Reviews (${_reviews.length})',
                    content: _isLoadingReviews
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
                                      Icon(Icons.error_outline, color: Colors.red[300]),
                                      const SizedBox(height: 8),
                                      Text(
                                        _reviewsError!,
                                        style: TextStyle(color: Colors.grey[600]),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextButton(
                                        onPressed: _fetchReviews,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
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
                                : Column(
                                    children: _reviews.map((review) {
                                      int ratingValue = 0;
                                      if (review['rating'] != null) {
                                        if (review['rating'] is int) {
                                          ratingValue = review['rating'] as int;
                                        } else if (review['rating'] is double) {
                                          ratingValue = (review['rating'] as double).round();
                                        } else if (review['rating'] is String) {
                                          ratingValue = int.tryParse(review['rating']) ?? 0;
                                        }
                                      }
                                      
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFF),
                                          borderRadius: BorderRadius.circular(12),
                                          border: const Border(
                                            left: BorderSide(
                                              color: Color(0xFF0B5ED7),
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    review['userName']?.toString() ?? 'Anonymous',
                                                    style: TextStyle(
                                                      fontSize: bodyFontSize,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF004780),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: List.generate(5, (index) {
                                                    return Icon(
                                                      index < ratingValue ? Icons.star : Icons.star_outline,
                                                      color: const Color(0xFFFFD700),
                                                      size: smallFontSize,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              review['review']?.toString() ?? '',
                                              style: TextStyle(
                                                fontSize: smallFontSize,
                                                color: const Color(0xFF5F6F81),
                                                height: 1.5,
                                              ),
                                            ),
                                            if (review['createdAt'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  _formatDate(review['createdAt'].toString()),
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
                                  ),
                    padding: cardPadding,
                    radius: cardRadius,
                  ),

                  // YouTube Videos
                  if (_youtubeUrls.isNotEmpty) ...[
                    if (_youtubeUrls.length > 1)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: isTablet ? 16 : 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Course Videos',
                              style: TextStyle(
                                fontSize: isDesktop ? 22 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Row(
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
                        left: horizontalPadding,
                        right: horizontalPadding,
                        top: _responsiveValue(12, 16, 20),
                        bottom: _responsiveValue(30, 40, 50),
                      ),
                      child: CommonYoutubePlayer(
                        youtubeUrl: _youtubeUrls[_currentVideoIndex],
                        height: videoHeight,
                        placeholderThumbnail: _getVideoThumbnail(
                            _youtubeUrls[_currentVideoIndex]),
                        borderRadius: 0,
                      ),
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.only(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        top: _responsiveValue(20, 30, 40),
                        bottom: _responsiveValue(30, 40, 50),
                      ),
                      child: CommonYoutubePlayer(
                        youtubeUrl:
                            'https://www.youtube.com/embed/NONufn3jgXI',
                        height: videoHeight,
                        placeholderThumbnail:
                            'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                        borderRadius: 0,
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding / 2,
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

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(_responsiveValue(12, 16, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(_scale(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF0B5ED7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: _responsiveValue(14, 16, 18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B5ED7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: _responsiveValue(11, 12, 13),
              color: const Color(0xFF5F6F81),
            ),
          ),
        ],
      ),
    );
  }
}