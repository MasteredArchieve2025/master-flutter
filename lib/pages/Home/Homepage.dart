import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/baseurl.dart';
import '../Blogs/BlogsScreen.dart';
import '../Blogs/BlogDetailsScreen.dart';
import '../Jobs/Jobs1.dart';
import '../../components/glass_loader.dart';

// ==================== HEADER WIDGET ====================
class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;

  const CustomHeader({
    super.key,
    this.title = "Master Archive",
    this.onProfilePressed,
    this.onSearchPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          
          Container(
            height: isIOS ? 52 : 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const SizedBox(width: 24),
                
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isIOS ? 18 : 19,
                        fontWeight: isIOS ? FontWeight.w600 : FontWeight.w700,
                        color: const Color(0xFF043771),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isSmallScreen) ...[
                        _buildIconButton(
                          icon: Icons.search,
                          size: 22,
                          onPressed: onSearchPressed,
                        ),
                        
                        const SizedBox(width: 14),
                        
                        _buildIconButton(
                          icon: Icons.notifications_outlined,
                          size: 22,
                          onPressed: onNotificationPressed,
                        ),
                        
                        const SizedBox(width: 14),
                      ] else ...[
                        _buildIconButton(
                          icon: Icons.search,
                          size: 20,
                          onPressed: onSearchPressed,
                        ),
                        
                        const SizedBox(width: 10),
                        
                        _buildIconButton(
                          icon: Icons.person_outline,
                          size: 24,
                          onPressed: onProfilePressed,
                        ),
                      ],
                      
                      if (!isSmallScreen)
                        _buildIconButton(
                          icon: Icons.person_outline,
                          size: 26,
                          onPressed: onProfilePressed,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required double size,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: size,
          color: const Color(0xFF083467),
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  bool _isAutoScrollStarted = false;
  int _footerIndex = 0;
  late bool isLargeScreen;
  late bool isExtraLargeScreen;

  // Advertisement Data
  List<String> _adImages = [];
  List<String> _youtubeUrls = [];
  bool _adsLoaded = false;
  bool _apiCallFailed = false;

  // Default banner data (fallback if API fails)
  final List<Map<String, String>> bannerData = [
    {
      "title": "Unlock Your Future at",
      "line1": "ARUNACHALA COLLEGE ",
      "line2": "ENGINEERING",
      "info": "Admissions Open for 2025-2026",
    },
    {
      "title": "Build Your Career With",
      "line1": "TOP ENGINEERING",
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

  // Choices list
  final List<Map<String, dynamic>> choices = [
    {"id": 1, "title": "School", "icon": Icons.school, "screen": "/school1"},
    {"id": 2, "title": "College", "icon": Icons.account_balance, "screen": "/college1"},
    {"id": 3, "title": "Course", "icon": Icons.laptop, "screen": "/course1"},
    {"id": 4, "title": "Exam", "icon": Icons.edit_document, "screen": "/exam1"},
    {"id": 5, "title": "IQ", "icon": Icons.psychology, "screen": "/iq1"},
    {"id": 6, "title": "Extra-Skills", "icon": Icons.music_note, "screen": "/extraskills1"},
  ];

  // Blog Data
  List<Blog> blogsData = [];
  bool _isBlogsLoading = true;
  String? _blogsErrorMessage;

  // Colleges Data
  final List<Map<String, dynamic>> collegesData = [
    {"id": 1, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 2, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 3, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 4, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 5, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 6, "name": "Arunachala College\nOf Engineering For Women"},
    {"id": 7, "name": "Arunachala College\nOf Engineering For Women"},
  ];

  List<Map<String, String>> get displayBanners {
    if (_adImages.isNotEmpty) {
      // Create banner items from API images
      return _adImages.map((imageUrl) {
        return {
          "title": "Welcome to",
          "line1": "MASTER ARCHIVE",
          "line2": "EDUCATION",
          "info": "Your Gateway to Success",
          "imageUrl": imageUrl,
        };
      }).toList();
    }
    return bannerData;
  }

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
    _loadHomeBlogs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<void> _loadHomeBlogs() async {
    setState(() {
      _isBlogsLoading = true;
      _blogsErrorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/blogs'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          blogsData = data.map((item) => Blog.fromJson(item)).toList();
          _isBlogsLoading = false;
        });
      } else {
        setState(() {
          _blogsErrorMessage = 'Failed to load blogs';
          _isBlogsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _blogsErrorMessage = e.toString();
        _isBlogsLoading = false;
      });
    }
  }

  Future<void> _loadAdvertisements() async {
    debugPrint('🔄 Loading advertisements for homepage...');
    
    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/advertisements?page=homepage'),
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
      debugPrint('✅ Using ${displayBanners.length} banners');
    }
  }

  void _startAutoScroll() {
    if (_isAutoScrollStarted) return;
    _isAutoScrollStarted = true;
    _autoScrollNext();
  }

  void _autoScrollNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= displayBanners.length) nextPage = 0;
        
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ).then((_) {
          if (mounted) _autoScrollNext();
        }).catchError((e) {
          _isAutoScrollStarted = false;
        });
      } else {
        _isAutoScrollStarted = false;
      }
    });
  }

  void _handleFooterNavigation(int index, BuildContext context) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _nextVideo() {
    if (_youtubeUrls.isEmpty) return;
    // Handle video navigation if needed
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
    _scrollController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    isLargeScreen = size.width >= 768;
    isExtraLargeScreen = size.width >= 1024;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomHeader(
              title: "Master Archive",
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner with API images
                    _buildCollegeBanner(),

                    // Info message when using fallback
                    if (_apiCallFailed && _adImages.isEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 40 : 20,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Using default banners',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Choice Section
                    _buildChoiceSection(),

                    // Blogs Section
                    _buildBlogsSection(),

                    // View Jobs Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 40 : 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052A2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 48 : 32,
                              vertical: isLargeScreen ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: isLargeScreen ? 22 : 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "View Jobs",
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                size: isLargeScreen ? 20 : 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Colleges Section
                    _buildTopCollegesSection(),
                  ],
                ),
              ),
            ),

            // Footer pinned at bottom
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
      ),
    );
  }

  Widget _buildCollegeBanner() {
    double bannerHeight = isLargeScreen ? 300 : 200;
    bool useApiImages = _adImages.isNotEmpty;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: bannerHeight,
            width: double.infinity,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: displayBanners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = displayBanners[index];
                
                if (useApiImages && item.containsKey('imageUrl')) {
                  // Show API image
                  return Container(
                    width: double.infinity,
                    child: Image.network(
                      item['imageUrl']!,
                      width: double.infinity,
                      height: bannerHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: bannerHeight,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0175D3), Color(0xFF014B85)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
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
                          height: bannerHeight,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0175D3), Color(0xFF014B85)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
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
                } else {
                  // Show default banner with text
                  return Container(
                    width: double.infinity,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0175D3), Color(0xFF014B85)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned(
                            right: isLargeScreen ? -20 : -20,
                            bottom: isLargeScreen ? -40 : -60,
                            child: Image.asset(
                              'assets/Global.png',
                              width: isLargeScreen ? 400 : 250,
                              height: isLargeScreen ? 300 : 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isLargeScreen ? 400 : 250,
                                  height: isLargeScreen ? 300 : 200,
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ),
                          
                          // Text Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item["title"]!,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD0F1FB),
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item["line1"]!,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                item["line2"]!,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item["info"]!,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 14 : 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
            children: List.generate(displayBanners.length, (index) {
              return Container(
                width: _currentBannerIndex == index ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: _currentBannerIndex == index 
                    ? const Color(0xFF014B85) 
                    : const Color(0xFFB0CFEA),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "YOUR CHOICE",
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: choices.map((choice) {
              final index = choices.indexOf(choice);
              final isEven = (index + 1) % 2 == 0;
              return _buildChoiceItem(choice, index, isEven);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceItem(Map<String, dynamic> choice, int index, bool isEven) {
    double ribbonWidth = isLargeScreen ? 160 : 230;
    double ribbonHeight = isLargeScreen ? 56 : 46;
    double cardHeight = isLargeScreen ? 70 : 59;
    double iconSize = isLargeScreen ? 32 : 28;

    return GestureDetector(
      onTap: () {
        print("Tapped: ${choice["title"]}");

        if (choice["screen"] != null) {
          Navigator.pushNamed(context, choice["screen"] as String);
        }
      },
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: isEven ? -18 : null,
              right: isEven ? null : -18,
              top: isLargeScreen ? 7 : 6.5,
              child: Image.asset(
                isEven ? 'assets/Ribbonleft.png' : 'assets/Ribbonright.png',
                width: ribbonWidth,
                height: ribbonHeight,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: ribbonWidth,
                    height: ribbonHeight,
                    decoration: BoxDecoration(
                      color: isEven ? const Color(0xFFE8F5E8) : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "🎀",
                        style: TextStyle(fontSize: isLargeScreen ? 24 : 20),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Container(
              height: cardHeight,
              margin: EdgeInsets.only(
                left: isEven ? 35 : 0,
                right: isEven ? 0 : 35,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: isLargeScreen ? 50 : 40,
                    child: !isEven
                        ? Icon(
                            choice["icon"] as IconData,
                            size: iconSize,
                            color: const Color(0xFF1a73e8),
                          )
                        : null,
                  ),
                  
                  Expanded(
                    child: Text(
                      choice["title"] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF003366),
                      ),
                    ),
                  ),
                  
                  SizedBox(
                    width: isLargeScreen ? 50 : 40,
                    child: isEven
                        ? Icon(
                            choice["icon"] as IconData,
                            size: iconSize,
                            color: const Color(0xFF1a73e8),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "VIEW BLOGS",
                style: TextStyle(
                  fontSize: isLargeScreen ? 22 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003366),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isBlogsLoading && blogsData.isEmpty)
            Center(
              child: Container(
                height: 150,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                  ),
                ),
              ),
            )
          else if (_blogsErrorMessage != null && blogsData.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(_blogsErrorMessage!),
                  TextButton(
                    onPressed: _loadHomeBlogs,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          else if (blogsData.isEmpty)
            const Center(child: Text("No blogs available"))
          else if (isLargeScreen)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: blogsData.take(4).map((blog) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 96) / 2 - 8,
                  child: _buildBlogCard(blog),
                );
              }).toList(),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: blogsData.length > 5 ? 5 : blogsData.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(
                      right: index < (blogsData.length > 5 ? 4 : blogsData.length - 1) ? 16 : 0,
                    ),
                    child: _buildBlogCard(blogsData[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(Blog blog) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailScreen(blog: blog),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                height: isLargeScreen ? 150 : 120,
                child: Image.network(
                  blog.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF0175D3).withOpacity(0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF0175D3).withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Color(0xFF0175D3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: blog.type == "NEWS" 
                            ? const Color(0xFFF0F7FF) 
                            : const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          blog.type,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 12 : 10,
                            fontWeight: FontWeight.w600,
                            color: blog.type == "NEWS" 
                              ? const Color(0xFF0072BC) 
                              : const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      
                      Text(
                        blog.time,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 12 : 10,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    blog.title,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF003366),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        size: isLargeScreen ? 14 : 12,
                        color: const Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        blog.category,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 12 : 10,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCollegesSection() {
    final topColleges = isLargeScreen 
      ? collegesData.take(4).toList()
      : collegesData.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOP RATED COLLEGES",
                style: TextStyle(
                  fontSize: isLargeScreen ? 22 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003366),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (isLargeScreen)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: topColleges.map((college) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 96) / 2 - 8,
                  child: _buildCollegeItem(college),
                );
              }).toList(),
            )
          else
            Column(
              children: topColleges.map((college) => _buildCollegeItem(college)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCollegeItem(Map<String, dynamic> college) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: isLargeScreen ? 80 : 70,
            margin: EdgeInsets.only(right: isLargeScreen ? 16 : 12),
            child: Row(
              children: [
                Text(
                  "▲",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: isLargeScreen ? 20 : 18,
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(
                  'assets/collegeicon.png',
                  width: isLargeScreen ? 48 : 42,
                  height: isLargeScreen ? 48 : 42,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isLargeScreen ? 48 : 42,
                      height: isLargeScreen ? 48 : 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0175D3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "AC",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      college["name"] as String,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF003366),
                        height: 1.3,
                      ),
                    ),
                  ),
                  
                  Column(
                    children: [
                      Text(
                        college["id"].toString(),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "🏆",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}