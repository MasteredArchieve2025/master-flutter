import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../../Widgets/Footer.dart';
import 'Jobs2.dart';
import 'Jobs4.dart'; // Add this import for Jobs4

class JobsScreen extends StatefulWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  int _footerIndex = 0;
  
  // Ad Banner Variables
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  late bool isTablet;
  late bool isWeb;

  // Advertisement data
  final List<Map<String, String>> ads = [
    {
      "id": "1",
      "title": "Study Abroad Scholarships",
      "description": "Get up to 50% scholarship on international programs",
      "image": "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop",
    },
    {
      "id": "2",
      "title": "Online Learning Platform",
      "description": "Access 1000+ courses for free this month",
      "image": "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop",
    },
    {
      "id": "3",
      "title": "Career Development Program",
      "description": "Boost your career with our certified programs",
      "image": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop",
    },
  ];

  bool get isIOS {
    if (kIsWeb) return false;
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  String _getFontFamily() {
    if (kIsWeb) return 'Roboto';
    return isIOS ? '.SF Pro Text' : 'Roboto';
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;
    final adHeight = screenSize.height * 0.25 > 200 ? 200.0 : screenSize.height * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header with SafeArea
          SafeArea(
            bottom: false,
            child: _buildHeader(context),
          ),
          
          // Main Content with CustomScrollView
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Ad Banner Section
                SliverToBoxAdapter(
                  child: _buildAdBanner(context, adHeight),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        const Text(
                          "Jobs & Careers",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Find the right job for your skills",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontFamily: _getFontFamily(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Search by Category Section
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JobCategoriesScreen(),
                              ),
                            );
                          },
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                maxWidth: 350,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0052A2),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0052A2).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 32,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Search Jobs by Category",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Browse roles, tech, or design",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: _getFontFamily(),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Browse Categories",
                                          style: TextStyle(
                                            color: Color(0xFF0052A2),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: const Color(0xFF0052A2).withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Popular for Students Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Popular for Students",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle view all
                              },
                              child: Text(
                                "View All",
                                style: TextStyle(
                                  color: const Color(0xFF0052A2),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: _getFontFamily(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category Chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildCategoryChip("Internships", Icons.work_outline),
                            _buildCategoryChip("Entry Level", Icons.trending_up),
                            _buildCategoryChip("Remote", Icons.home_work_outlined),
                            _buildCategoryChip("Part Time", Icons.access_time),
                            _buildCategoryChip("Full Time", Icons.business_center),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Recommended Jobs Section
                        const Text(
                          "Recommended Jobs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Job Cards - Now tappable to navigate to JobDetailsScreen
                        _buildJobCard(
                          company: "Google",
                          position: "Associate UI Designer",
                          location: "Mountain View, CA",
                          logo: Icons.g_mobiledata,
                          logoColor: Colors.blue,
                          tags: ["Full Time", "Design"],
                          salary: "\$80k - \$120k",
                          postedTime: "Posted 2 days ago",
                          isNew: true,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildJobCard(
                          company: "Apple",
                          position: "Product Design Intern",
                          location: "Cupertino, CA",
                          logo: Icons.apple,
                          logoColor: Colors.black,
                          tags: ["Internship", "Design"],
                          salary: "\$45k - \$60k",
                          postedTime: "Posted 5 hours ago",
                          isNew: false,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildJobCard(
                          company: "Microsoft",
                          position: "Junior Backend Dev",
                          location: "Redmond, WA",
                          logo: Icons.window,
                          logoColor: Colors.blue,
                          tags: ["Full Time", "Development"],
                          salary: "\$70k - \$95k",
                          postedTime: "Posted 1 week ago",
                          isNew: false,
                        ),
                        const SizedBox(height: 28),

                        // Upload Resume Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052A2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0052A2).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Upload Your Resume",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Let top recruiters find you first. Get noticed by over 500+ companies.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                  fontFamily: _getFontFamily(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle upload
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0052A2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Upload Now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Video Section - Edge to edge
                SliverToBoxAdapter(
                  child: _buildVideoPlaceholder(),
                ),

                // No spacing after video
              ],
            ),
          ),

          // Footer
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
    );
  }

  // Header from School1Screen adapted for JobsScreen
  Widget _buildHeader(BuildContext context) {
    // Get responsive header height
    double getHeaderHeight() {
      if (isWeb) return 64; // Desktop
      if (isTablet) return 58; // Tablet
      return 52; // Mobile
    }

    // Get responsive font size
    double getTitleFontSize() {
      if (isWeb) return 19;
      if (isTablet) return 18;
      return 17;
    }

    // Get responsive horizontal padding
    double getHorizontalPadding() {
      if (isWeb) return 40; // Desktop
      if (isTablet) return 24; // Tablet
      return 16; // Mobile
    }

    // Get max content width
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
            // Back Button
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
            
            // Title
            Expanded(
              child: Center(
                child: Text(
                  "Jobs & Careers",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getTitleFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Spacer for symmetry
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
                      SnackBar(content: Text('Opening: ${ad['title']}')),
                    );
                  },
                  child: Stack(
                    children: [
                      Image.network(
                        ad['image']!,
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
                              ad['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isIOS ? 18 : 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: _getFontFamily(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ad['description']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isIOS ? 14 : 15,
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

  // YouTube Video Placeholder - Edge to edge
  Widget _buildVideoPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 16), // Small top margin only
      width: double.infinity,
      child: Container(
        width: double.infinity,
        height: isWeb ? 400 : (isTablet ? 320 : 250),
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: NetworkImage(
              'https://img.youtube.com/vi/qYapc_bkfxw/maxresdefault.jpg',
            ),
            fit: BoxFit.cover,
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
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0052A2)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
                fontFamily: _getFontFamily(),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Updated Job Card with GestureDetector for navigation
  Widget _buildJobCard({
    required String company,
    required String position,
    required String location,
    required IconData logo,
    required Color logoColor,
    List<String>? tags,      // Added for JobDetailsScreen
    String? salary,           // Added for JobDetailsScreen
    String? postedTime,       // Added for JobDetailsScreen
    bool isNew = false,       // Added for JobDetailsScreen
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to JobDetailsScreen with job details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(
              jobTitle: position,
              company: company,
              location: location,
              tags: tags,
              salary: salary,
              postedTime: postedTime,
              isNew: isNew,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Company Logo Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: logoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                logo,
                size: 30,
                color: logoColor,
              ),
            ),
            const SizedBox(width: 16),
            // Job Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          position,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$company • $location",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: _getFontFamily(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: tags!.take(2).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            // Bookmark Icon
            Icon(
              Icons.bookmark_outline,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}