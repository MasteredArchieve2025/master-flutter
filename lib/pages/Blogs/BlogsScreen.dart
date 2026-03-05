// blogs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'BlogDetailsScreen.dart'; // This imports the Blog class
import '../../Widgets/Footer.dart';
import '../../Widgets/CommonYoutubePlayer.dart';
import '../../Api/baseurl.dart';
import '../../components/glass_loader.dart';

// Advertisement data
class Ad {
  final String id;
  final String title;
  final String description;
  final String image;
  final String url;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.url,
  });
}

final List<Ad> ads = [
  Ad(
    id: "1",
    title: "Study Abroad Scholarships",
    description: "Get up to 50% scholarship on international programs",
    image:
        "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop",
    url: "https://example.com/scholarship",
  ),
  Ad(
    id: "2",
    title: "Online Learning Platform",
    description: "Access 1000+ courses for free this month",
    image:
        "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop",
    url: "https://example.com/study-abroad",
  ),
  Ad(
    id: "3",
    title: "Career Development Program",
    description: "Boost your career with our certified programs",
    image:
        "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop",
    url: "https://example.com/courses",
  ),
];

// Static blogsData removed to use dynamic API data
List<Blog> blogsData = [];

// Tab categories
class TabItem {
  final String id;
  final String label;

  const TabItem({required this.id, required this.label});
}

final List<TabItem> tabs = const [
  TabItem(id: "all", label: "All"),
  TabItem(id: "news", label: "Education News"),
  TabItem(id: "blogs", label: "Expert Blogs"),
];

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  String activeTab = "all";
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  late bool isTablet;
  late bool isWeb;

  // API State
  bool _isLoading = true;
  String? _errorMessage;

  // Platform detection function - works on all platforms including web
  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAdAutoScroll();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/blogs'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          blogsData = data.map((item) => Blog.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load blogs. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAdAutoScroll() {
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          currentAdIndex = (currentAdIndex + 1) % ads.length;
        });
        _pageController.animateToPage(
          currentAdIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Blog> getFilteredBlogs() {
    if (activeTab == "all") return blogsData;
    if (activeTab == "news") {
      return blogsData.where((blog) => blog.type == "NEWS").toList();
    }
    if (activeTab == "blogs") {
      return blogsData.where((blog) => blog.type == "BLOG").toList();
    }
    return blogsData;
  }

  Color getTypeColor(String type) {
    return type == "NEWS"
        ? const Color(0xFF003366).withOpacity(0.1)
        : const Color(0xFF4CAF50).withOpacity(0.1);
  }

  Color getTypeTextColor(String type) {
    return type == "NEWS" ? const Color(0xFF003366) : const Color(0xFF2E7D32);
  }

  // Responsive font sizes
  double getHeaderTitleFontSize() {
    if (isWeb) return 22;
    return isIOS ? 20 : 22;
  }

  double getAdTitleFontSize() {
    if (kIsWeb) return 20;
    return isIOS ? 18 : 20;
  }

  double getAdDescFontSize() {
    if (kIsWeb) return 15;
    return isIOS ? 14 : 15;
  }

  double getTabFontSize() {
    if (kIsWeb) return 15;
    return isIOS ? 14 : 15;
  }

  EdgeInsets getTabPadding() {
    if (kIsWeb) return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    return EdgeInsets.symmetric(
      horizontal: isIOS ? 14 : 16,
      vertical: isIOS ? 8 : 10,
    );
  }

  double getTabMargin() {
    if (kIsWeb) return 20;
    return isIOS ? 16 : 20;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;
    final adHeight = isWeb ? 300.0 : (isTablet ? 300.0 : 200.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with SafeArea
              SafeArea(
                bottom: false,
                child: _buildHeader(context),
              ),

              // Main Content
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Advertisement Banner
                    SliverToBoxAdapter(
                      child: _buildAdBanner(context, adHeight),
                    ),

                    // Tab Navigation
                    SliverToBoxAdapter(
                      child: _buildTabBar(),
                    ),

                    // Blog List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: _isLoading && blogsData.isEmpty
                          ? const SliverFillRemaining(
                              child: SizedBox.shrink(),
                            )
                          : _errorMessage != null && blogsData.isEmpty
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            size: 48, color: Colors.red),
                                        const SizedBox(height: 16),
                                        Text(_errorMessage!),
                                        ElevatedButton(
                                          onPressed: _fetchBlogs,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : blogsData.isEmpty
                                  ? const SliverFillRemaining(
                                      child:
                                          Center(child: Text("No blogs found")),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final blogs = getFilteredBlogs();
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: _buildBlogCard(blogs[index]),
                                          );
                                        },
                                        childCount: getFilteredBlogs().length,
                                      ),
                                    ),
                    ),

                    // Info Banner
                    SliverToBoxAdapter(
                      child: _buildInfoBanner(),
                    ),

                    // Video Section
                    SliverToBoxAdapter(
                      child: _buildVideoSection(isTablet),
                    ),
                  ],
                ),
              ),

              // Footer pinned at bottom
              const Footer(),
            ],
          ),
          // GlassLoader overlay
          if (_isLoading)
            const GlassLoader(
              message: 'Loading blogs...',
            ),
        ],
      ),
    );
  }

  // Fixed Header from School1Screen
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
                  "Blogs And News",
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

  Widget _buildAdBanner(BuildContext context, double adHeight) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: adHeight,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentAdIndex = index;
                });
              },
              children: ads.map((ad) {
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening: ${ad.title}')),
                    );
                  },
                  child: Stack(
                    children: [
                      Image.network(
                        ad.image,
                        width: screenWidth,
                        height: adHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth,
                            height: adHeight,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: getAdTitleFontSize(),
                                fontWeight: FontWeight.w700,
                                fontFamily: _getFontFamily(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ad.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: getAdDescFontSize(),
                                fontFamily: _getFontFamily(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Ad",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Dots Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(ads.length, (index) {
                return Container(
                  width: currentAdIndex == index ? 20.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: currentAdIndex == index
                        ? const Color(0xFF0B5ED7)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: kIsWeb ? 52 : (isIOS ? 48 : 52),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isActive = activeTab == tab.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                activeTab = tab.id;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: tab.id == tabs.last.id ? 0 : (isIOS ? 16 : 20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isIOS ? 14 : 16,
                vertical: isIOS ? 8 : 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isActive ? const Color(0xFF0B5ED7) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: getTabFontSize(),
                  fontWeight: isActive
                      ? (kIsWeb
                          ? FontWeight.w700
                          : (isIOS ? FontWeight.w600 : FontWeight.w700))
                      : (kIsWeb
                          ? FontWeight.w600
                          : (isIOS ? FontWeight.w500 : FontWeight.w600)),
                  color:
                      isActive ? const Color(0xFF0B5ED7) : Colors.grey.shade600,
                  fontFamily: _getFontFamily(),
                ),
              ),
            ),
          );
        }).toList(),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Blog Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                blog.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),

            // Blog Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with type and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getTypeColor(blog.type),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          blog.type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getTypeTextColor(blog.type),
                            fontFamily: _getFontFamily(),
                          ),
                        ),
                      ),
                      Text(
                        blog.time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: _getFontFamily(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    blog.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF003366),
                      fontFamily: _getFontFamily(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    blog.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                      fontFamily: _getFontFamily(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Footer with category and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          blog.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0072BC),
                            fontFamily: _getFontFamily(),
                          ),
                        ),
                      ),
                      Text(
                        blog.date,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          fontFamily: _getFontFamily(),
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

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4c73ac),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest Educational Content",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: _getFontFamily(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Stay updated with news, blogs and expert insights",
            style: TextStyle(
              color: const Color(0xFFDCE8FF),
              fontSize: 12,
              fontFamily: _getFontFamily(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(bool isTablet) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with padding only on sides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Educational Videos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF003366),
                    fontFamily: _getFontFamily(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening YouTube')),
                    );
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: const Color(0xFF0B5ED7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: _getFontFamily(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Video Container - Full width, no horizontal padding
          CommonYoutubePlayer(
            youtubeUrl: 'https://www.youtube.com/watch?v=qYapc_bkfxw',
            height: isTablet ? 320 : 250,
            placeholderThumbnail:
                'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg',
            borderRadius: 0,
          ),
        ],
      ),
    );
  }
}
