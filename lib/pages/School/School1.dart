import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';

// ==================== SCHOOL SCREEN ====================
class School1Screen extends StatefulWidget {
  const School1Screen({super.key});

  @override
  State<School1Screen> createState() => _School1ScreenState();
}

class _School1ScreenState extends State<School1Screen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  int _footerIndex = 0;
  late bool isTablet;
  late bool isWeb;

  // API Data
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  String? _pageName;

  // Banner Data (fallback if API fails)
  final List<Map<String, String>> bannerData = [
    {
      "title": "Unlock Your Future at",
      "line1": "ARUNACHALA MATRICULATION",
      "line2": "SCHOOL",
      "info": "Admissions Open for 2025-2026",
    },
    {
      "title": "Build Your Career With",
      "line1": "TOP TUTION CENTRE",
      "line2": "PROGRAMS",
      "info": "Apply Now",
    },
    {
      "title": "Learn. Innovate. Lead.",
      "line1": "QUALITY",
      "line2": "EDUCATION",
      "info": "Join Today",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<void> _fetchAdvertisements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=schoolpage1'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final apiData = data['data'];
          
          setState(() {
            _pageName = apiData['page_name'];
            
            // Parse images
            if (apiData['images'] != null && apiData['images'] is List) {
              _adImages = List<String>.from(apiData['images']);
            }
            
            // Parse youtube URLs
            if (apiData['youtube_urls'] != null && apiData['youtube_urls'] is List) {
              _youtubeUrls = List<String>.from(apiData['youtube_urls']);
            }
            
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load advertisements';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _currentBannerIndex + 1;
        int itemCount = _adImages.isNotEmpty ? _adImages.length : bannerData.length;
        if (nextPage >= itemCount) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isTablet = size.width >= 768;
    isWeb = size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Header with SafeArea
              SafeArea(
                bottom: false,
                child: _buildHeader(context),
              ),
              
              // Main Content
              Expanded(
                child: _buildContent(context, size),
              ),
              
              // Footer
              Footer(
                currentIndex: _footerIndex,
                onItemTapped: (index) {
                  if (mounted) {
                    setState(() {
                      _footerIndex = index;
                    });
                    _handleFooterNavigation(index, context);
                  }
                },
              ),
            ],
          ),
          
          // Glass Loader
          if (_isLoading)
            const GlassLoader(
              message: 'Loading content...',
            ),
        ],
      ),
    );
  }

  void _handleFooterNavigation(int index, BuildContext context) {
    switch (index) {
      case 0: // Home
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1: // Charity
        // Add your charity screen navigation here
        break;
      case 2: // Feedback
        // Add your feedback screen navigation here
        break;
      case 3: // Profile
        // Add your profile screen navigation here
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    double getHeaderHeight() {
      if (isWeb) return 64;
      if (isTablet) return 58;
      return 52;
    }

    double getTitleFontSize() {
      if (isWeb) return 19;
      if (isTablet) return 18;
      return 17;
    }

    double getHorizontalPadding() {
      if (isWeb) return 40;
      if (isTablet) return 24;
      return 16;
    }

    double maxContentWidth = isWeb ? 1200 : double.infinity;

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
                  "School & Tuitions",
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

  Widget _buildContent(BuildContext context, Size size) {
    if (_errorMessage != null) {
      return Center(
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
              'Failed to load content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
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
              onPressed: _fetchAdvertisements,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B5ED7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner Slider with API images
          _buildBannerSlider(size.width),
          
          // 2 Column Grid
          _buildGridSection(),

          // Browse by Category Section
          _buildBrowseByCategorySection(),
          
          // YouTube Video Placeholder with API URL
          _buildVideoPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(double bannerWidth) {
    // Use API images if available, otherwise use fallback banner data
    bool useApiImages = _adImages.isNotEmpty;
    int itemCount = useApiImages ? _adImages.length : bannerData.length;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isWeb ? 0 : (isTablet ? 24 : 0),
      ),
      child: Column(
        children: [
          SizedBox(
            height: isTablet ? 300 : 200,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: itemCount,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                if (useApiImages) {
                  // Show API image
                  return Container(
                    width: bannerWidth,
                    height: isTablet ? 300 : 200,
                    child: Image.network(
                      _adImages[index],
                      width: bannerWidth,
                      height: isTablet ? 300 : 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: bannerWidth,
                          height: isTablet ? 300 : 200,
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
                                  'Image ${index + 1}',
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
                          width: bannerWidth,
                          height: isTablet ? 300 : 200,
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
                } else {
                  // Show fallback banner with text
                  final item = bannerData[index];
                  return Container(
                    width: bannerWidth,
                    child: Stack(
                      children: [
                        // Background Image
                        Image.asset(
                          'assets/Global.png',
                          width: bannerWidth,
                          height: isTablet ? 300 : 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: bannerWidth,
                              height: isTablet ? 300 : 200,
                              color: const Color(0xFF0052A2),
                            );
                          },
                        ),
                        
                        // Overlay
                        Container(
                          width: bannerWidth,
                          height: isTablet ? 300 : 200,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                          ),
                          padding: EdgeInsets.all(isTablet ? 32 : 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"]!,
                                style: TextStyle(
                                  color: const Color(0xFFE8F0FF),
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item["line1"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 28 : 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                item["line2"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 28 : 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item["info"]!,
                                style: TextStyle(
                                  color: const Color(0xFFFFD966),
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          
          // Pagination Dots
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                width: _currentBannerIndex == index ? 16 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentBannerIndex == index 
                    ? const Color(0xFF0B5ED7) 
                    : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
      ),
      margin: EdgeInsets.only(top: isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View School Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/school2');
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: 8,
                  top: isTablet ? 20 : 15,
                ),
                child: _buildGridCard(
                  icon: Icons.business,
                  title: "View School",
                  subtitle: "Explore Schools for you",
                ),
              ),
            ),
          ),
          
          // View Tuitions Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/tutions1');
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: 8,
                  top: isTablet ? 20 : 15,
                ),
                child: _buildGridCard(
                  icon: Icons.book,
                  title: "View Tuitions",
                  subtitle: "Explore Tuitions for all Standards",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWeb ? 40 : (isTablet ? 32 : 27)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isTablet ? 48 : 40,
            color: const Color(0xFF0B5ED7),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseByCategorySection() {
    final List<Map<String, dynamic>> schoolCategories = [
      {"title": "CBSE", "icon": Icons.account_balance, "color": const Color(0xFF4F46E5)},
      {"title": "STATE BOARD", "icon": Icons.school, "color": const Color(0xFF059669)},
      {"title": "MATRICULATION", "icon": Icons.workspace_premium, "color": const Color(0xFFDC2626)},
      {"title": "PLAY SCHOOL", "icon": Icons.child_care, "color": const Color(0xFFEA580C)},
      {"title": "ICSE", "icon": Icons.menu_book, "color": const Color(0xFF2563EB)},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : (isTablet ? 24 : 16),
      ),
      margin: EdgeInsets.only(top: isTablet ? 40 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Browse by Category",
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isTablet ? 120 : 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: schoolCategories.length,
              itemBuilder: (context, index) {
                final cat = schoolCategories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/school2',
                      arguments: cat["title"],
                    );
                  },
                  child: Container(
                    width: isTablet ? 140 : 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cat["color"].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat["icon"],
                            color: cat["color"],
                            size: isTablet ? 28 : 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cat["title"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    // Use first YouTube URL from API if available
    String videoUrl = _youtubeUrls.isNotEmpty 
        ? _youtubeUrls.first 
        : 'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg';
    
    // Extract video ID for thumbnail
    String thumbnailUrl = videoUrl;
    if (videoUrl.contains('youtube.com/embed/')) {
      final videoId = videoUrl.split('/').last;
      thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }

    return GestureDetector(
      onTap: () {
        if (_youtubeUrls.isNotEmpty) {
          // Open YouTube video in browser or show in WebView
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening video: $_youtubeUrls'),
              duration: const Duration(seconds: 2),
            ),
          );
          // In a real app, you would launch the URL:
          // launchUrl(Uri.parse(_youtubeUrls.first));
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: isTablet ? 70 : 55,
        ),
        width: double.infinity,
        child: Container(
          width: double.infinity,
          height: isWeb ? 400 : (isTablet ? 320 : 250),
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: NetworkImage(thumbnailUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Fallback to default image
              },
            ),
          ),
          child: Center(
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
    );
  }
}