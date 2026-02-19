import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../../Widgets/Footer.dart';
import 'Jobs4.dart'; // Import Jobs4

class ITSoftwareJobsScreen extends StatefulWidget {
  const ITSoftwareJobsScreen({Key? key}) : super(key: key);

  @override
  State<ITSoftwareJobsScreen> createState() => _ITSoftwareJobsScreenState();
}

class _ITSoftwareJobsScreenState extends State<ITSoftwareJobsScreen> {
  String selectedFilter = "All";
  
  final List<String> filters = ["All", "Full Time", "Internship", "Remote"];
  
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
          // Header with SafeArea (fixed)
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section
                        const SizedBox(height: 8),
                        const Text(
                          "IT & Software Job List",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "IT & Software Jobs",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: filters.map((filter) {
                              final isSelected = selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedFilter = filter;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFF0052A2),
                                  checkmarkColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Job Card 1 - Junior Frontend Developer
                        _buildJobCard(
                          title: "Junior Frontend Developer",
                          company: "TechNova Solutions",
                          isNew: true,
                          tags: ["Remote", "Full Time"],
                          salary: "\$45k - \$60k",
                          postedTime: "Posted 2 days ago",
                        ),
                        const SizedBox(height: 16),

                        // Job Card 2 - Software Engineer Intern
                        _buildJobCard(
                          title: "Software Engineer Intern",
                          company: "DataFlow Systems",
                          location: "Bangalore",
                          tags: ["Internship"],
                          duration: "6 Months",
                          postedTime: "Posted 5 hours ago",
                        ),
                        const SizedBox(height: 16),

                        // Job Card 3 - Backend Developer
                        _buildJobCard(
                          title: "Backend Developer (Go/Node)",
                          company: "CloudScale Inc.",
                          tags: ["Hybrid", "Full Time"],
                          postedTime: "Posted 1 week ago",
                        ),
                        const SizedBox(height: 16),

                        // Job Card 4 - QA Automation Intern
                        _buildJobCard(
                          title: "QA Automation Intern",
                          company: "Nexus Lab",
                          location: "Pune, IN",
                          tags: ["Internship"],
                          postedTime: "Posted 3 days ago",
                        ),
                        const SizedBox(height: 20),
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
            currentIndex: 0,
            onItemTapped: (index) {
              // Handle footer navigation
            },
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
                  "IT & Software",
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
      margin: const EdgeInsets.only(top: 16),
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

  Widget _buildJobCard({
    required String title,
    required String company,
    String? location,
    bool isNew = false,
    required List<String> tags,
    String? salary,
    String? duration,
    required String postedTime,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Jobs4Screen with job details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(
              jobTitle: title,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and NEW tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Company name
            Text(
              company,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // Location if exists
            if (location != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Tags row
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
                if (salary != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      salary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Posted time and View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  postedTime,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Text(
                  "View Details",
                  style: TextStyle(
                    color: Color(0xFF0052A2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}