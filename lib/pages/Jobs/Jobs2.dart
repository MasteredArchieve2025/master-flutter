import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Widgets/Footer.dart';
import '../../Api/baseurl.dart';
import 'Jobs3.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class JobCategory {
  final int id;
  final String name;
  final String description;
  final String image;
  final int sortOrder;

  JobCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.sortOrder,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class JobCategoriesScreen extends StatefulWidget {
  const JobCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<JobCategoriesScreen> createState() => _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends State<JobCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Ad Banner ──
  int currentAdIndex = 0;
  late PageController _pageController;
  Timer? _adTimer;
  late bool isTablet;
  late bool isWeb;

  final List<Map<String, String>> ads = [
    {
      "id": "1",
      "title": "Study Abroad Scholarships",
      "description": "Get up to 50% scholarship on international programs",
      "image":
          "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&h=300&fit=crop",
    },
    {
      "id": "2",
      "title": "Online Learning Platform",
      "description": "Access 1000+ courses for free this month",
      "image":
          "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&h=300&fit=crop",
    },
    {
      "id": "3",
      "title": "Career Development Program",
      "description": "Boost your career with our certified programs",
      "image":
          "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=300&fit=crop",
    },
  ];

  // ── API state ──
  List<JobCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    _fetchCategories();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Fetch job categories from API ─────────────────────────────────────────

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/job-categories'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          List<JobCategory> loaded = [];

          // API can return a single object OR a list
          if (data is List) {
            loaded = data
                .map((item) =>
                    JobCategory.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data is Map<String, dynamic>) {
            loaded = [JobCategory.fromJson(data)];
          }

          setState(() {
            _categories = loaded;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No categories found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories.\n$e';
        _isLoading = false;
      });
    }
  }

  // ── Ad auto-scroll ────────────────────────────────────────────────────────

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

  // ── Icon / colour mapping ─────────────────────────────────────────────────

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('it') || n.contains('software') || n.contains('tech')) {
      return Icons.computer;
    } else if (n.contains('gov')) {
      return Icons.account_balance;
    } else if (n.contains('bank') || n.contains('finance')) {
      return Icons.attach_money;
    } else if (n.contains('edu') || n.contains('teach')) {
      return Icons.school;
    } else if (n.contains('health') || n.contains('medical') ||
        n.contains('pharma')) {
      return Icons.local_hospital;
    } else if (n.contains('market') || n.contains('sales')) {
      return Icons.trending_up;
    } else if (n.contains('manage') || n.contains('hr')) {
      return Icons.business_center;
    } else if (n.contains('engineer')) {
      return Icons.engineering;
    } else if (n.contains('design') || n.contains('ui') ||
        n.contains('ux')) {
      return Icons.brush;
    } else {
      return Icons.work_outline;
    }
  }

  Color _colorForIndex(int index) {
    const colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  // ── Filtered list ─────────────────────────────────────────────────────────

  List<JobCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    isTablet = screenSize.width >= 768;
    isWeb = screenSize.width >= 1024;
    final adHeight =
        screenSize.height * 0.25 > 200 ? 200.0 : screenSize.height * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _buildHeader(context),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Ad Banner ──
                SliverToBoxAdapter(
                  child: _buildAdBanner(context, adHeight),
                ),

                // ── Category content ──
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
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Dynamic categories ──
                        _buildCategoryList(),
                      ],
                    ),
                  ),
                ),

                // ── Video placeholder ──
                SliverToBoxAdapter(
                  child: _buildVideoPlaceholder(),
                ),
              ],
            ),
          ),

          // Footer
          const Footer(),
        ],
      ),
    );
  }

  // ── Category list (loading / error / data) ────────────────────────────────

  Widget _buildCategoryList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFF0052A2)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: _getFontFamily(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052A2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No categories found.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontFamily: _getFontFamily(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_filteredCategories.length, (index) {
        final cat = _filteredCategories[index];
        final isLast = index == _filteredCategories.length - 1;
        return _buildCategoryItem(
          icon: _iconForCategory(cat.name),
          iconColor: _colorForIndex(index),
          title: cat.name,
          subtitle: cat.description,
          showDivider: !isLast,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ITSoftwareJobsScreen(
                  categoryName: cat.name,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
        padding: EdgeInsets.symmetric(horizontal: getHorizontalPadding()),
        height: getHeaderHeight(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    size: 24, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
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
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  // ── Ad Banner ─────────────────────────────────────────────────────────────

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
                    fit: StackFit.expand,
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
                              horizontal: 10, vertical: 5),
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

          // Dots
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

  // ── Category row ──────────────────────────────────────────────────────────

  Widget _buildCategoryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showDivider = true,
    required VoidCallback onTap,
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
            child: Icon(icon, color: iconColor, size: 26),
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
          trailing: Icon(Icons.arrow_forward_ios,
              color: Colors.grey.shade400, size: 16),
          onTap: onTap,
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

  // ── Video placeholder ─────────────────────────────────────────────────────

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
            child: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }
}