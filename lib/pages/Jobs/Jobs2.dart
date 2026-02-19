import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../../Widgets/Footer.dart'; // Adjust path as needed
import 'Jobs3.dart';


class JobCategoriesScreen extends StatefulWidget {
  const JobCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<JobCategoriesScreen> createState() => _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends State<JobCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
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
          // Header with SafeArea (like School1Screen)
          SafeArea(
            bottom: false,
            child: _buildHeader(context),
          ),
          
          // Main Content with CustomScrollView for better control
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Ad Banner Section
                SliverToBoxAdapter(
                  child: _buildAdBanner(context, adHeight),
                ),

                // Categories Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          "Job Categories",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search categories...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                                fontFamily: _getFontFamily(),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                                size: 22,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              // Handle search
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Categories List
                        _buildCategoryItem(
                          icon: Icons.computer,
                          iconColor: Colors.blue,
                          title: "IT & Software",
                          subtitle: "Developer, Data Science, UI/UX",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.account_balance,
                          iconColor: Colors.purple,
                          title: "Government Jobs",
                          subtitle: "State & Central Level Openings",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.attach_money,
                          iconColor: Colors.green,
                          title: "Banking & Finance",
                          subtitle: "IBPS, SBI, Private Banks",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.school,
                          iconColor: Colors.orange,
                          title: "Education",
                          subtitle: "Teaching, Research, Administration",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.local_hospital,
                          iconColor: Colors.red,
                          title: "Healthcare",
                          subtitle: "Nursing, Pharma, Medical Labs",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.trending_up,
                          iconColor: Colors.teal,
                          title: "Marketing & Sales",
                          subtitle: "Digital Marketing, Sales, Branding",
                        ),
                        
                        _buildCategoryItem(
                          icon: Icons.business_center,
                          iconColor: Colors.indigo,
                          title: "Management",
                          subtitle: "HR, Operations, Project Manager",
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // YouTube Video Section - Edge to edge
                SliverToBoxAdapter(
                  child: _buildVideoPlaceholder(),
                ),

                // No spacing after video - video directly above footer
              ],
            ),
          ),

          // Footer
          const Footer(),
        ],
      ),
    );
  }

  // Header from School1Screen adapted for JobCategories
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
                  "Job Categories",
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

  Widget _buildCategoryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: _getFontFamily(),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ), onTap: () {
          // Navigate to Jobs3Screen when category is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ITSoftwareJobsScreen(),
            ),
          );
          },
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 72,
          ),
      ],
    );
  }

  // YouTube Video Placeholder - Edge to edge (like School1Screen)
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
}