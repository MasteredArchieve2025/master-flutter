// lib/pages/Extraskills/Extraskills1.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';
import 'Extraskills2.dart';

class Extraskills1Screen extends StatefulWidget {
  const Extraskills1Screen({super.key});

  @override
  State<Extraskills1Screen> createState() => _Extraskills1ScreenState();
}

class _Extraskills1ScreenState extends State<Extraskills1Screen> {
  int _currentCarouselIndex = 0;
  int _currentVideoIndex = 0;
  final PageController _pageController = PageController();
  
  // Loading states
  bool _isLoading = true;
  bool _isLoadingAds = true;
  String? _errorMessage;

  // API Data
  List<Map<String, dynamic>> _categories = [];
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];

  // Default banner ads (fallback if API fails) - Using same style as School3
  final List<String> _defaultBannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Default activities (fallback if API fails)
  final List<Map<String, dynamic>> _defaultActivities = [
    {
      'id': 1,
      'title': 'Fine Arts',
      'icon': Icons.palette,
      'description': 'Drawing, Painting, Sculpture',
      'image': null,
    },
    {
      'id': 2,
      'title': 'Driving Class',
      'icon': Icons.directions_car,
      'description': 'Learn driving skills',
      'image': null,
    },
    {
      'id': 3,
      'title': 'Athlete',
      'icon': Icons.directions_run,
      'description': 'Sports and athletics',
      'image': null,
    },
    {
      'id': 4,
      'title': 'Sports & Fitness',
      'icon': Icons.sports_soccer,
      'description': 'Football, Cricket, Yoga',
      'image': null,
    },
    {
      'id': 5,
      'title': 'Home Science',
      'icon': Icons.local_laundry_service,
      'description': 'Cooking, Sewing, Home Management',
      'image': null,
    },
    {
      'id': 6,
      'title': 'Other Classes',
      'icon': Icons.library_music,
      'description': 'Music, Photography, Writing',
      'image': null,
    },
  ];

  List<String> get bannerAds => _adImages.isNotEmpty ? _adImages : _defaultBannerAds;
  List<Map<String, dynamic>> get activities => _categories.isNotEmpty ? _categories : _defaultActivities;

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    _loadCategories();
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for extraskillpage1...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=extraskillpage1'),
      );

      debugPrint('📡 Ads API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];

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
            _isLoadingAds = false;
          });
        }
      } else {
        debugPrint('⚠️ Ads API error: ${response.statusCode}');
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

  Future<void> _loadCategories() async {
    debugPrint('🔄 Loading extra skill categories...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/extra-skill-categories'),
      );

      debugPrint('📡 Categories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📦 Loaded ${data.length} categories');

        setState(() {
          _categories = data.map((item) {
            // Fix image URL if needed
            String? imageUrl = item['image'];
            if (imageUrl != null && imageUrl.isNotEmpty) {
              // Check if URL is valid
              if (!imageUrl.startsWith('http')) {
                imageUrl = '${BaseUrl.baseUrl}$imageUrl';
              }
            }

            return {
              'id': item['id'] ?? DateTime.now().millisecondsSinceEpoch,
              'title': item['name'] ?? 'Unknown',
              'description': item['shortDescription'] ?? 'Explore this skill category',
              'image': imageUrl, // Store image URL for potential use
              'icon': _getIconForCategory(item['name'] ?? ''), // Map to appropriate icon
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('⚠️ Categories API error: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to load categories';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(String name) {
    // Map category names to appropriate icons
    final lowerName = name.toLowerCase();
    if (lowerName.contains('fine arts') || lowerName.contains('art')) {
      return Icons.palette;
    } else if (lowerName.contains('driving')) {
      return Icons.directions_car;
    } else if (lowerName.contains('athlete') || lowerName.contains('sports')) {
      return Icons.directions_run;
    } else if (lowerName.contains('fitness')) {
      return Icons.sports_soccer;
    } else if (lowerName.contains('home science')) {
      return Icons.local_laundry_service;
    } else if (lowerName.contains('music')) {
      return Icons.library_music;
    } else if (lowerName.contains('photography')) {
      return Icons.photo_camera;
    } else if (lowerName.contains('writing')) {
      return Icons.edit;
    } else if (lowerName.contains('programming') || lowerName.contains('coding')) {
      return Icons.code;
    } else {
      return Icons.star; // Default icon
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
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients && mounted) {
        int nextPage = _currentCarouselIndex + 1;
        if (nextPage >= bannerAds.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1400 : double.infinity;
    final int numColumns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final double videoHeight = isMobile ? 220 : (isTablet ? 280 : 360);
    
    // Card dimensions
    final double cardWidth = (screenWidth - (horizontalPadding * 2) - 
                            (_responsiveValue(12, 16, 20) * (numColumns - 1))) / numColumns;

    // Start auto-scroll after ads are loaded
    if (!_isLoadingAds && _pageController.hasClients) {
      _startAutoScroll();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ===== HEADER =====
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052A2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    height: _responsiveValue(52, 72, 80),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            size: _responsiveValue(18, 26, 28),
                            color: Colors.white,
                          ),
                        ),
                        // Title
                        Expanded(
                          child: Center(
                            child: Text(
                              'Extra Skills',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _responsiveValue(20, 22, 24),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Spacer for symmetry
                        SizedBox(width: _responsiveValue(40, 44, 48)),
                      ],
                    ),
                  ),
                ),

                // ===== MAIN CONTENT =====
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlassLoader(
                            message: 'Loading skills...',
                          ),
                        )
                      : _errorMessage != null && _categories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading categories',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });
                                      _loadCategories();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B5ED7),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Center(
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // ===== BANNER CAROUSEL (Full width like School3) =====
                                      SizedBox(
                                        height: _responsiveValue(160, 240, 280),
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: bannerAds.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentCarouselIndex = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return Container(
                                              width: double.infinity,
                                              child: Image.network(
                                                bannerAds[index],
                                                width: double.infinity,
                                                height: _responsiveValue(160, 240, 280),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: _responsiveValue(160, 240, 280),
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
                                                    width: double.infinity,
                                                    height: _responsiveValue(160, 240, 280),
                                                    color: const Color(0xFF0052A2),
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                loadingProgress.expectedTotalBytes!
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
                                      SizedBox(height: _responsiveValue(12, 16, 20)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: bannerAds.asMap().entries.map((entry) {
                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: _currentCarouselIndex == entry.key 
                                              ? _responsiveValue(20, 22, 24) 
                                              : _responsiveValue(8, 9, 10),
                                            height: _responsiveValue(8, 9, 10),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: _responsiveValue(4, 5, 6),
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentCarouselIndex == entry.key
                                                ? const Color(0xFF0B5ED7)
                                                : const Color(0xFFCCCCCC),
                                              borderRadius: BorderRadius.circular(_responsiveValue(4, 5, 6)),
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                      // ===== ACTIVITIES GRID =====
                                      Container(
                                        width: double.infinity,
                                        color: Colors.white,
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          _responsiveValue(24, 28, 32),
                                          horizontalPadding,
                                          _responsiveValue(24, 28, 32),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Section Title
                                            Text(
                                              'Skill Categories',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(20, 22, 24),
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF003366),
                                              ),
                                            ),
                                            SizedBox(height: _responsiveValue(8, 10, 12)),
                                            
                                            // Section Subtitle with count
                                            Text(
                                              _categories.isNotEmpty
                                                  ? '${_categories.length} skill ${_categories.length == 1 ? 'category' : 'categories'} available'
                                                  : 'Explore different skill categories to enhance your abilities',
                                              style: TextStyle(
                                                fontSize: _responsiveValue(14, 15, 16),
                                                color: const Color(0xFF666666),
                                                height: 1.5,
                                              ),
                                            ),
                                            SizedBox(height: _responsiveValue(20, 24, 28)),

                                            // Grid View
                                            if (activities.isEmpty)
                                              const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Text('No skill categories available'),
                                                ),
                                              )
                                            else
                                              Wrap(
                                                spacing: _responsiveValue(12, 16, 20),
                                                runSpacing: _responsiveValue(12, 16, 20),
                                                children: activities.map((activity) {
                                                  return _buildActivityCard(
                                                    activity: activity,
                                                    width: cardWidth,
                                                  );
                                                }).toList(),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // ===== YOUTUBE VIDEO SECTION (Full width like School3) =====
                                      if (_youtubeUrls.isNotEmpty) ...[
                                        if (_youtubeUrls.length > 1)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: horizontalPadding,
                                              vertical: _responsiveValue(12, 16, 20),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Videos',
                                                  style: TextStyle(
                                                    fontSize: _responsiveValue(18, 20, 22),
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: _previousVideo,
                                                      icon: const Icon(Icons.chevron_left, color: Color(0xFF0B5ED7)),
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
                                                      icon: const Icon(Icons.chevron_right, color: Color(0xFF0B5ED7)),
                                                      constraints: const BoxConstraints(),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        Container(
                                          width: double.infinity,
                                          height: videoHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                _getVideoThumbnail(_youtubeUrls[_currentVideoIndex]),
                                              ),
                                              fit: BoxFit.cover,
                                              onError: (exception, stackTrace) {},
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: GestureDetector(
                                                  onTap: () => _showUrlDialog(_youtubeUrls[_currentVideoIndex]),
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
                                      ] else
                                        // Fallback video
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: _responsiveValue(20, 30, 40),
                                          ),
                                          width: double.infinity,
                                          height: videoHeight,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                'https://img.youtube.com/vi/L2zqTYgcpfg/maxresdefault.jpg',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () => _showUrlDialog('https://www.youtube.com/embed/L2zqTYgcpfg'),
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
          
          // Full screen loader for initial loading
          if (_isLoading && _categories.isEmpty)
            const GlassLoader(
              message: 'Loading extra skills...',
            ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildActivityCard({
    required Map<String, dynamic> activity,
    required double width,
  }) {
    // Check if we have an image from API and it's valid
    bool hasValidImage = activity['image'] != null && 
                         activity['image'].toString().isNotEmpty &&
                         !activity['image'].toString().contains('example.com');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills2Screen(
              categoryTitle: activity['title'] as String,
              categoryId: activity['id'] as int?,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: width,
          padding: EdgeInsets.all(_responsiveValue(16, 18, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Image Container
              Container(
                width: _responsiveValue(56, 64, 72),
                height: _responsiveValue(56, 64, 72),
                decoration: BoxDecoration(
                  gradient: hasValidImage
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF2295D2), Color(0xFF284598)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(_responsiveValue(12, 14, 16)),
                  image: hasValidImage
                      ? DecorationImage(
                          image: NetworkImage(activity['image']),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Fallback to gradient on error
                          },
                        )
                      : null,
                ),
                child: !hasValidImage
                    ? Center(
                        child: Icon(
                          activity['icon'] as IconData,
                          size: _responsiveValue(28, 32, 36),
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              
              SizedBox(height: _responsiveValue(12, 14, 16)),

              // Title
              Text(
                activity['title'] as String,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004780),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: _responsiveValue(8, 9, 10)),

              // Description
              Text(
                activity['description'] as String,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
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
      ),
    );
  }

  // Show URL dialog for YouTube
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External Link'),
        content: Text('Would you like to open the video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening video: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}