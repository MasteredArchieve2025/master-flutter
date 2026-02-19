// lib/pages/Blogs/BlogDetailsScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../../Widgets/Footer.dart'; // Add Footer import

// ============ BLOG MODEL DEFINITION ============
// Define Blog class here ONLY
class Blog {
  final String id;
  final String title;
  final String description;
  final String type;
  final String time;
  final String date;
  final String category;
  final String image;
  final String readTime;
  final String author;
  final String authorRole;
  final String publishStatus;
  final String publishDate;
  final String authorBio;
  final String content;
  final String authorImage;
  final String blogImage;

  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.time,
    required this.date,
    required this.category,
    required this.image,
    required this.readTime,
    required this.author,
    required this.authorRole,
    required this.publishStatus,
    required this.publishDate,
    required this.authorBio,
    required this.content,
    required this.authorImage,
    required this.blogImage,
  });
}

// ============ AD MODEL ============
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

// ============ RELATED UPDATE MODEL ============
class RelatedUpdate {
  final String id;
  final String title;
  final String type;
  final String date;

  RelatedUpdate({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
  });
}

// ============ ADVERTISEMENT DATA ============
final List<Ad> ads = [
  Ad(
    id: "1",
    title: "Study Abroad Scholarships",
    description: "Get up to 50% scholarship on international programs",
    image: "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop",
    url: "https://example.com/scholarship",
  ),
  Ad(
    id: "2",
    title: "Online Learning Platform",
    description: "Access 1000+ courses for free this month",
    image: "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop",
    url: "https://example.com/study-abroad",
  ),
  Ad(
    id: "3",
    title: "Career Development Program",
    description: "Boost your career with our certified programs",
    image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop",
    url: "https://example.com/courses",
  ),
];

// ============ RELATED UPDATES DATA ============
final List<RelatedUpdate> relatedUpdates = [
  RelatedUpdate(
    id: "1",
    title: "The Future of Remote Learning",
    type: "BLOG",
    date: "Oct 22",
  ),
  RelatedUpdate(
    id: "2",
    title: "New Engineering Syllabus 2025",
    type: "NEWS",
    date: "2 hrs ago",
  ),
  RelatedUpdate(
    id: "3",
    title: "Mental Health in Academia",
    type: "BLOG",
    date: "Oct 20",
  ),
];

// ============ BLOG DETAIL SCREEN ============
class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  const BlogDetailScreen({Key? key, required this.blog}) : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  late bool isTablet;
  late bool isWeb;

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAdAutoScroll();
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

  double getHeaderTitleFontSize() {
    if (kIsWeb) return 22;
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

  Color getTypeColor(String type) {
    return type == "NEWS"
        ? const Color(0xFF003366).withOpacity(0.1)
        : const Color(0xFF4CAF50).withOpacity(0.1);
  }

  Color getTypeTextColor(String type) {
    return type == "NEWS" ? const Color(0xFF003366) : const Color(0xFF2E7D32);
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
    final adHeight = screenSize.height * 0.25 > 200 ? 200.0 : screenSize.height * 0.25;
    final blog = widget.blog;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Column(
        children: [
          // Header with SafeArea (like School1Screen)
          SafeArea(
            bottom: false,
            child: _buildHeader(context, blog),
          ),

          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Advertisement Banner
                SliverToBoxAdapter(
                  child: _buildAdBanner(context, adHeight),
                ),
                
                // Blog Content
                SliverToBoxAdapter(
                  child: _buildBlogContent(context, blog),
                ),
                
                // YouTube Video Section
                SliverToBoxAdapter(
                  child: _buildVideoSection(isTablet),
                ),
                
                // No extra SizedBox - video directly above footer
              ],
            ),
          ),

          // Footer - Using imported Footer widget
          const Footer(),
        ],
      ),
    );
  }

  // Fixed Header from School1Screen
  Widget _buildHeader(BuildContext context, Blog blog) {
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
                  blog.type == "NEWS" ? "News Detail" : "Expert Blog",
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

  Widget _buildBlogContent(BuildContext context, Blog blog) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type and read time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getTypeColor(blog.type),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  blog.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: getTypeTextColor(blog.type),
                    fontFamily: _getFontFamily(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                blog.readTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: _getFontFamily(),
                ),
              ),
            ],
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              blog.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF003366),
                fontFamily: _getFontFamily(),
                height: 1.3,
              ),
            ),
          ),
          
          // Author info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.author,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                  fontFamily: _getFontFamily(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                blog.authorRole,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontFamily: _getFontFamily(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    blog.publishStatus,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    blog.publishDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontFamily: _getFontFamily(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Blog image
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                blog.blogImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const Divider(color: Color(0xFFE0E0E0), height: 1, thickness: 1),
          
          // Blog content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              blog.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey.shade800,
                fontFamily: _getFontFamily(),
              ),
            ),
          ),
          
          // Author bio section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(blog.authorImage),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                // Author bio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About ${blog.author}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF003366),
                          fontFamily: _getFontFamily(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        blog.authorBio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                          fontFamily: _getFontFamily(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Related updates section
          Text(
            'Related Updates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003366),
              fontFamily: _getFontFamily(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Related updates list
          ...relatedUpdates.map((update) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getTypeColor(update.type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    update.type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: getTypeTextColor(update.type),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF003366),
                          fontFamily: _getFontFamily(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        update.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: _getFontFamily(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Video Container - Full width, edge to edge
          Container(
            height: isTablet ? 280 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YouTube Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: _getFontFamily(),
                    ),
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