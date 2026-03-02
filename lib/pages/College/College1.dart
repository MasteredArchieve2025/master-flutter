import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../Widgets/Footer.dart';
import '../../components/glass_loader.dart';
import 'College2.dart';
import '../../Api/School/Colleges/College_service.dart';
import '../../Api/baseurl.dart';

class College1Screen extends StatefulWidget {
  const College1Screen({super.key});

  @override
  State<College1Screen> createState() => _College1ScreenState();
}

class _College1ScreenState extends State<College1Screen> {
  int _footerIndex = 0;
  int _activeAd = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;
  
  // Add these state variables
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  int _currentVideoIndex = 0;

  // Banner Ads Data (keep as is)
  final List<String> _defaultBannerAds = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&auto=format&fit=crop',
  ];

  List<String> get bannerAds => _adImages.isNotEmpty ? _adImages : _defaultBannerAds;

  @override
  void initState() {
    super.initState();
    
    _fetchCategories();
    _loadAdvertisements();
    _startAdTimer();
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for collegepage1...');
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=collegepage1'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          setState(() {
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            if (apiData['youtube_urls'] != null && apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
            _isLoadingAds = false;
          });
        } else {
          setState(() { _isLoadingAds = false; });
        }
      } else {
        setState(() { _isLoadingAds = false; });
      }
    } catch (e) {
      debugPrint('❌ Error loading advertisements: $e');
      setState(() { _isLoadingAds = false; });
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

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await CollegeService.getCollegeCategories();
      setState(() {
        _categories = categories.map((cat) => cat.toCategoryMap()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

  // Responsive methods (keep as is)
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    final double horizontalPadding = _getHorizontalPadding(context);
    final double bannerHeight = isDesktop ? 220 : (isTablet ? 300 : 180);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
            // HEADER (keep as is)
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: _getHeaderHeight(context),
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
                          'Colleges',
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
                        // TOP AUTO SCROLL AD BANNER (keep as is)
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

                        // Dots Indicator (keep as is)
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

                        // BODY - Categories Section with API data
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 0 : horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isTablet ? 20 : 16,
                                  bottom: isTablet ? 16 : 12,
                                  left: isDesktop ? horizontalPadding : 0,
                                  right: isDesktop ? horizontalPadding : 0,
                                ),
                                child: Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 26 : (isTablet ? 24 : 20),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0C2F63),
                                  ),
                                ),
                              ),

                              // Categories Grid with Loading/Error states
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isDesktop ? horizontalPadding : (isTablet ? 20 : 10),
                                  right: isDesktop ? horizontalPadding : (isTablet ? 20 : 10),
                                  bottom: isTablet ? 40 : 30,
                                ),
                                child: _buildCategoriesContent(
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                ),
                              ),
                            ],
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Videos',
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
                                        icon: const Icon(Icons.chevron_left, color: Color(0xFF0B5ED7)),
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
                                        icon: const Icon(Icons.chevron_right, color: Color(0xFF0B5ED7)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: _youtubeUrls.length > 1 ? 0 : (isTablet ? 40 : 30),
                            ),
                            child: CommonYoutubePlayer(
                              youtubeUrl: _youtubeUrls[_currentVideoIndex],
                              height: isDesktop ? 360 : (isTablet ? 280 : 220),
                              placeholderThumbnail: _getVideoThumbnail(_youtubeUrls[_currentVideoIndex]),
                              borderRadius: 0,
                            ),
                          ),
                        ] else
                          // VIDEO AD - EDGE TO EDGE (keep as is)
                          Padding(
                            padding: EdgeInsets.only(
                              top: isTablet ? 40 : 30,
                            ),
                            child: CommonYoutubePlayer(
                              youtubeUrl: 'https://www.youtube.com/embed/NONufn3jgXI',
                              height: isDesktop ? 360 : (isTablet ? 280 : 220),
                              placeholderThumbnail: 'https://img.youtube.com/vi/NONufn3jgXI/maxresdefault.jpg',
                              borderRadius: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FOOTER (keep as is)
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
      ),
      if (_isLoading)
        const GlassLoader(message: 'Loading categories...'),
    ],
  ),
);
}

// New method to build categories content with loading/error states
Widget _buildCategoriesContent({
required bool isTablet,
required bool isDesktop,
}) {
if (_isLoading) {
  return const SizedBox(height: 200); // Placeholder while loading
}

    if (_errorMessage != null) {
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
                'Failed to load categories',
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
                onPressed: _fetchCategories,
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

    if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No categories available',
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

    // Build the categories grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final int crossAxisCount = isDesktop ? 3 : (isTablet ? 3 : 2);
        final double spacing = isTablet ? 20 : 16;
        final double runSpacing = isTablet ? 35 : 30;
        final double totalSpacing = spacing * (crossAxisCount - 1);
        final double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: WrapAlignment.center,
          children: _categories.map((category) {
            return SizedBox(
              width: itemWidth,
              child: _buildCategoryCard(
                category: category,
                isTablet: isTablet,
                isDesktop: isDesktop,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required Map<String, dynamic> category,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => College2Screen(
              category: category,
            ),
          ),
        );
        // Optional: Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${category['name']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 15)),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon Container - You can use the category image here if available
            Container(
              width: isDesktop ? 80 : (isTablet ? 75 : 60),
              height: isDesktop ? 80 : (isTablet ? 75 : 60),
              margin: EdgeInsets.only(
                bottom: isDesktop ? 15 : (isTablet ? 12 : 10),
              ),
              decoration: BoxDecoration(
                color: category['color'] as Color,
                borderRadius: BorderRadius.circular(12),
                // Uncomment below to use category image if you prefer
                // image: category['image'] != null && category['image'].isNotEmpty
                //     ? DecorationImage(
                //         image: NetworkImage(category['image']),
                //         fit: BoxFit.cover,
                //       )
                //     : null,
              ),
              child: Icon(
                category['icon'] as IconData,
                size: isDesktop ? 40 : (isTablet ? 40 : 30),
                color: Colors.white,
              ),
            ),
            
            // Category Name
            Text(
              category['name'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0C2F63),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              category['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 14 : (isTablet ? 14 : 12),
                color: Colors.grey,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}