// blogs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'BlogDetailsScreen.dart'; // This imports the Blog class
import '../../Widgets/Footer.dart';

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

// Blog data - using Blog class from BlogDetailsScreen.dart
final List<Blog> blogsData = [
  Blog(
    id: "1",
    title: "New Engineering Syllabus Announced",
    description: "The University board has released the updated curriculum focusing on AI and sustainable energy.",
    type: "NEWS",
    time: "2 hrs ago",
    date: "Oct 26",
    category: "Curriculum",
    image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=250&fit=crop",
    readTime: "3 min read",
    author: "University Board",
    authorRole: "Education Board",
    publishStatus: "Published",
    publishDate: "2 hrs ago",
    authorBio: "The University board regulates curriculum standards and updates for engineering programs nationwide.",
    content: "The University board has released the updated curriculum focusing on AI and sustainable energy.\n\nKey Changes in the 2025 Syllabus:\n- AI and Machine Learning integrated into all engineering streams\n- Sustainable Energy Systems as a core subject\n- Industry 4.0 technologies including IoT and Robotics\n- Enhanced practical training with 60% lab-based learning\n\nThe new syllabus aims to prepare students for emerging technologies and global challenges.",
    authorImage: "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=400&fit=crop",
  ),
  Blog(
    id: "2",
    title: "5 Study Hacks to Boost Your IQ",
    description: "Discover scientifically proven methods to enhance memory retention and focus during exams.",
    type: "BLOG",
    time: "Yesterday",
    date: "Oct 25",
    category: "Study Tips",
    image: "https://images.unsplash.com/photo-1456513080510-34499c4359ce?w=400&h=250&fit=crop",
    readTime: "5 min read",
    author: "Sarah Jenkins",
    authorRole: "Education Specialist",
    publishStatus: "Published",
    publishDate: "Yesterday, 4:30 PM",
    authorBio: "Sarah has over 10 years of experience in cognitive psychology and student mentorship. She loves helping students unlock their full potential.",
    content: "Discover scientifically proven methods to enhance your cognitive abilities and memory retention during exam preparation.\n\n1. Active Recall Practice\n   Instead of re-reading notes, test yourself regularly. This strengthens neural pathways and improves long-term memory retention.\n\n2. Spaced Repetition\n   Review material at increasing intervals. Studies show this can improve retention by up to 200%.\n\n3. Mindfulness Meditation\n   Just 10 minutes daily can improve focus, reduce stress, and enhance cognitive flexibility.\n\n4. Sleep Optimization\n   7-8 hours of quality sleep consolidates learning and improves problem-solving abilities.\n\n5. Nutrition for Brain Health\n   Omega-3 fatty acids, antioxidants, and proper hydration support optimal brain function.\n\nImplement these strategies consistently for 30 days, and you'll notice significant improvements in your learning efficiency and cognitive performance.",
    authorImage: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1456513080510-34499c4359ce?w=800&h=400&fit=crop",
  ),
  Blog(
    id: "3",
    title: "Scholarship Applications Now Open",
    description: "Arunachala College announces new merit-based scholarships for top performing students.",
    type: "NEWS",
    time: "Oct 24",
    date: "Oct 24",
    category: "Scholarship",
    image: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&h=250&fit=crop",
    readTime: "4 min read",
    author: "Arunachala College",
    authorRole: "Administration",
    publishStatus: "Published",
    publishDate: "Oct 24",
    authorBio: "Arunachala College is committed to providing quality education and opportunities to deserving students across the country.",
    content: "Arunachala College announces new merit-based scholarships for top performing students in the 2025 academic year.\n\nScholarship Details:\n- Merit Scholarships: Up to 100% tuition fee waiver for top 10 rank holders\n- Sports Scholarships: For national and state level athletes\n- Arts Scholarships: For students excelling in cultural activities\n- Need-based Scholarships: For economically disadvantaged students\n\nApplication Deadline: November 30, 2024\nResults Announcement: December 15, 2024",
    authorImage: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=400&fit=crop",
  ),
  Blog(
    id: "4",
    title: "Online Learning Platforms Comparison",
    description: "A comprehensive review of top online education platforms for 2025.",
    type: "BLOG",
    time: "Oct 22",
    date: "Oct 22",
    category: "Technology",
    image: "https://images.unsplash.com/photo-1542744095-fcf48d80b0fd?w=400&h=250&fit=crop",
    readTime: "6 min read",
    author: "Tech Education Team",
    authorRole: "Technology Analysts",
    publishStatus: "Published",
    publishDate: "Oct 22",
    authorBio: "Our team of technology analysts specializes in reviewing and comparing educational platforms to help students make informed choices.",
    content: "A comprehensive review of top online education platforms for 2025.\n\nPlatform Comparison:\n1. Coursera - Best for university-level courses\n2. Udemy - Best for skill-based courses\n3. edX - Best for academic rigor\n4. Khan Academy - Best for free foundational learning\n5. Skillshare - Best for creative skills\n\nEach platform offers unique advantages depending on your learning goals and budget.",
    authorImage: "https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1542744095-fcf48d80b0fd?w=800&h=400&fit=crop",
  ),
  Blog(
    id: "5",
    title: "Mental Health Awareness Week",
    description: "College organizes workshops and sessions focusing on student mental wellbeing.",
    type: "NEWS",
    time: "Oct 20",
    date: "Oct 20",
    category: "Student Life",
    image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=250&fit=crop",
    readTime: "4 min read",
    author: "College Wellness Center",
    authorRole: "Student Support",
    publishStatus: "Published",
    publishDate: "Oct 20",
    authorBio: "The College Wellness Center is dedicated to supporting student mental health and overall wellbeing.",
    content: "College organizes workshops and sessions focusing on student mental wellbeing during Mental Health Awareness Week.\n\nWeek's Schedule:\n- Monday: Stress Management Workshop\n- Tuesday: Mindfulness Meditation Sessions\n- Wednesday: Counseling Services Open House\n- Thursday: Peer Support Group Meetings\n- Friday: Wellness Fair with Local Organizations\n\nAll events are free and open to all students.",
    authorImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&h=400&fit=crop",
  ),
  Blog(
    id: "6",
    title: "Career Guidance for Freshmen",
    description: "Essential tips for first-year students to plan their career path effectively.",
    type: "BLOG",
    time: "Oct 18",
    date: "Oct 18",
    category: "Career",
    image: "https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=250&fit=crop",
    readTime: "5 min read",
    author: "Career Services Department",
    authorRole: "Career Counselors",
    publishStatus: "Published",
    publishDate: "Oct 18",
    authorBio: "Our career services team helps students navigate their career paths from freshman year to graduation and beyond.",
    content: "Essential tips for first-year students to plan their career path effectively.\n\nKey Steps for Freshmen:\n1. Self-Assessment: Identify your interests, skills, and values\n2. Explore Options: Research different career paths and industries\n3. Build Network: Connect with professors, alumni, and professionals\n4. Gain Experience: Look for internships and volunteer opportunities\n5. Develop Skills: Focus on both technical and soft skills development\n\nStart early to make the most of your college experience.",
    authorImage: "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&h=400&fit=crop",
    blogImage: "https://images.unsplash.com/photo-1553877522-43269d4ea984?w=800&h=400&fit=crop",
  ),
];

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
    return type == "NEWS" 
        ? const Color(0xFF003366)
        : const Color(0xFF2E7D32);
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
    final adHeight = screenSize.height * 0.3 > 250 ? 250.0 : screenSize.height * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Column(
        children: [
          // Header with SafeArea (like School1Screen)
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final blogs = getFilteredBlogs();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBlogCard(blogs[index]),
                        );
                      },
                      childCount: getFilteredBlogs().length,
                    ),
                  ),
                ),

                // Banner
                SliverToBoxAdapter(
                  child: _buildInfoBanner(),
                ),

                // YouTube Video Section
                SliverToBoxAdapter(
                  child: _buildVideoSection(isTablet),
                ),

                // No spacing after video
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
                    color: isActive ? const Color(0xFF0B5ED7) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: getTabFontSize(),
                  fontWeight: isActive 
                      ? (kIsWeb ? FontWeight.w700 : (isIOS ? FontWeight.w600 : FontWeight.w700))
                      : (kIsWeb ? FontWeight.w600 : (isIOS ? FontWeight.w500 : FontWeight.w600)),
                  color: isActive ? const Color(0xFF0B5ED7) : Colors.grey.shade600,
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