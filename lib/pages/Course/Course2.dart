// lib/pages/Course/Course2.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../components/glass_loader.dart';
import '../../api/baseurl.dart';
import 'Course3.dart';

class Course2Screen extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  const Course2Screen({
    super.key,
    required this.categoryData,
  });

  @override
  State<Course2Screen> createState() => _Course2ScreenState();
}

class _Course2ScreenState extends State<Course2Screen> {
  int _activeAd = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  // Course items from API
  List<Map<String, dynamic>> _courseItems = [];

  // Ads and Videos
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;

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
    _fetchCourseItems();
    _loadAdvertisements();
    _startAdTimer();
  }

  // Fetch course items by categoryId
  Future<void> _fetchCourseItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final categoryId = widget.categoryData['id'] ?? widget.categoryData['_id'];
    
    if (categoryId == null) {
      setState(() {
        _errorMessage = 'Category ID not found';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/course-items?categoryId=$categoryId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Handle the response structure: { "success": true, "data": [...] }
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          
          setState(() {
            // Sort by sortOrder if available
            data.sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));
            _courseItems = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load courses: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Load advertisements for coursepage2
  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for coursepage2...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=coursepage2'),
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
      debugPrint('❌ Error loading advertisements: $e');
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  // Video navigation methods
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
    super.dispose();
  }

  // Scale function for responsive sizing
  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2; // Desktop
    if (screenWidth >= 768) return size * 1.1; // Tablet
    return size; // Mobile
  }

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop; // Desktop
    if (screenWidth >= 768) return tablet; // Tablet
    return mobile; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double bannerHeight = _responsiveValue(200, 300, 300);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final double videoHeight = _responsiveValue(250, 320, 400);

    // Calculate columns based on screen size
    final int columns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final double gap = _responsiveValue(12, 16, 20);
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (gap * (columns - 1))) /
            columns;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // App Bar
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
                    borderRadius: isDesktop
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : null,
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(52, 58, 64),
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
                              widget.categoryData['name']?.toString() ?? 'Courses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(17, 18, 19),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // MAIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: maxContentWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TOP AUTO SCROLL AD BANNER
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
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                  color: Color(0xFF0B5ED7)),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    size: 60,
                                                    color:
                                                        const Color(0xFF0B5ED7),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Advertisement ${index + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xFF0B5ED7),
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              children:
                                  List.generate(bannerAds.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: _activeAd == index ? 24 : 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: _activeAd == index
                                        ? const Color(0xFF0B5ED7)
                                        : const Color(0xFFCCCCCC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),

                            // Category Description (if available)
                            if (widget.categoryData['description'] != null)
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: _responsiveValue(16, 20, 24),
                                ),
                                padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(_responsiveValue(10, 12, 14)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.categoryData['description'].toString(),
                                  style: TextStyle(
                                    fontSize: _responsiveValue(14, 15, 16),
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // Section Title
                            Container(
                              margin: EdgeInsets.only(
                                left: horizontalPadding,
                                right: horizontalPadding,
                                top: _responsiveValue(8, 10, 12),
                                bottom: _responsiveValue(12, 16, 20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Available Courses',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(18, 20, 22),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0C2F63),
                                    ),
                                  ),
                                  Text(
                                    '${_courseItems.length} items',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Course Items Grid
                            if (_isLoading)
                              Container(
                                height: 300,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0052A2),
                                  ),
                                ),
                              )
                            else if (_errorMessage != null)
                              _buildErrorWidget(isDesktop, isTablet)
                            else if (_courseItems.isEmpty)
                              _buildEmptyWidget(isDesktop, isTablet)
                            else
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: gap,
                                      runSpacing: _responsiveValue(14, 16, 20),
                                      alignment: WrapAlignment.start,
                                      children: _courseItems.map((item) {
                                        return SizedBox(
                                          width: cardWidth,
                                          child: _buildCourseCard(
                                            item: item,
                                            cardWidth: cardWidth,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),

                            // ===== YOUTUBE VIDEO SECTION =====
                            if (_youtubeUrls.isNotEmpty) ...[
                              if (_youtubeUrls.length > 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: isTablet ? 16 : 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                  top: _youtubeUrls.length > 1
                                      ? 0
                                      : (isTablet ? 40 : 30),
                                  bottom: _responsiveValue(30, 40, 50),
                                ),
                                child: CommonYoutubePlayer(
                                  youtubeUrl: _youtubeUrls[_currentVideoIndex],
                                  height:
                                      isDesktop ? 400 : (isTablet ? 320 : 250),
                                  placeholderThumbnail: _getVideoThumbnail(
                                      _youtubeUrls[_currentVideoIndex]),
                                  borderRadius: 0,
                                ),
                              ),
                            ] else
                              // Default VIDEO - EDGE TO EDGE
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isTablet ? 40 : 30,
                                  bottom: _responsiveValue(30, 40, 50),
                                ),
                                child: CommonYoutubePlayer(
                                  youtubeUrl:
                                      'https://www.youtube.com/embed/NONufn3jgXI',
                                  height:
                                      isDesktop ? 400 : (isTablet ? 320 : 250),
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
              ],
            ),
          ),
          if (_isLoading) const GlassLoader(message: 'Loading courses...'),
        ],
      ),
    );
  }

  // Error widget
  Widget _buildErrorWidget(bool isDesktop, bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load courses',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCourseItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052A2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty widget
  Widget _buildEmptyWidget(bool isDesktop, bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No courses available in this category',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> item,
    required double cardWidth,
  }) {
    final String itemName = item['name']?.toString() ?? 'Unnamed Course';
    final String description = item['description']?.toString() ?? 'Explore this professional course';
    final String imageUrl = item['image']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        // Navigate to Course3 with selected course
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Course3Screen(
              title: itemName,
              courseData: item, // Pass full course data
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $itemName'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(_scale(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_scale(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _scale(4),
              offset: Offset(0, _scale(2)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Course Image
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(_scale(12)),
                child: Image.network(
                  imageUrl,
                  width: cardWidth - _scale(24),
                  height: _scale(100),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: cardWidth - _scale(24),
                      height: _scale(100),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(_scale(12)),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: _scale(30),
                        color: Colors.grey.shade500,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: cardWidth - _scale(24),
                height: _scale(100),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(_scale(12)),
                ),
                child: Icon(
                  Icons.menu_book,
                  size: _scale(30),
                  color: Colors.grey.shade500,
                ),
              ),

            SizedBox(height: _scale(10)),

            // Title
            Text(
              itemName,
              style: TextStyle(
                fontSize: _scale(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004780),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: _scale(4)),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: _scale(11),
                color: const Color(0xFF555555),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}