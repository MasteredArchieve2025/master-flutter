// lib/pages/Extraskills/Extraskills2.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';
import 'Extraskills3.dart';

class Extraskills2Screen extends StatefulWidget {
  final String categoryTitle;
  final List<Map<String, dynamic>>? sections; // Make it optional

  const Extraskills2Screen({
    super.key,
    required this.categoryTitle,
    this.sections, // Optional now
  });

  @override
  State<Extraskills2Screen> createState() => _Extraskills2ScreenState();
}

class _Extraskills2ScreenState extends State<Extraskills2Screen> {
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();

  // Get sections to display - handles null/empty sections
  List<Map<String, dynamic>> get _displaySections {
    // If sections were provided, use them
    if (widget.sections != null && widget.sections!.isNotEmpty) {
      return widget.sections!;
    }
    
    // Otherwise, generate default sections based on category
    return _getDefaultSectionsForCategory();
  }

  // Banner Ads
  final List<String> _bannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Skill Meta Data (icon + description map)
  final Map<String, Map<String, dynamic>> _skillMeta = {
    "Classical Dance": {'icon': Icons.music_note, 'desc': 'Learn traditional dance forms'},
    "Western Dance": {'icon': Icons.music_note, 'desc': 'Modern and freestyle dance styles'},
    "Folk Dance": {'icon': Icons.music_note, 'desc': 'Cultural and folk traditions'},
    "Zumba / Fitness Dance": {'icon': Icons.fitness_center, 'desc': 'Fitness through dance'},
    "Freestyle & Choreography Training": {'icon': Icons.theater_comedy, 'desc': 'Creative movement training'},
    
    "Classical Vocal": {'icon': Icons.mic, 'desc': 'Traditional vocal training'},
    "Western Vocal": {'icon': Icons.mic, 'desc': 'Western singing techniques'},
    "Devotional / Bhajan Singing": {'icon': Icons.music_note, 'desc': 'Spiritual vocal practice'},
    "Folk Music Singing": {'icon': Icons.music_note, 'desc': 'Folk music traditions'},
    "Voice Culture & Training": {'icon': Icons.record_voice_over, 'desc': 'Improve voice quality'},
    
    "Basic Drawing & Sketching": {'icon': Icons.brush, 'desc': 'Drawing fundamentals'},
    "Creative Art & Imagination Drawing": {'icon': Icons.lightbulb, 'desc': 'Creative expression'},
    "Thematic & Subject Drawing": {'icon': Icons.draw, 'desc': 'Concept-based art'},
    "Professional Art Techniques": {'icon': Icons.palette, 'desc': 'Advanced art skills'},
    "Art for School & Hobby": {'icon': Icons.school, 'desc': 'Art for students & hobbyists'},
    
    "Two Wheeler": {'icon': Icons.two_wheeler, 'desc': 'Bike driving skills'},
    "Four Wheeler": {'icon': Icons.directions_car, 'desc': 'Car driving training'},
    "Heavy Vehicle": {'icon': Icons.local_shipping, 'desc': 'Heavy vehicle driving'},
    "Driving Rules": {'icon': Icons.traffic, 'desc': 'Traffic rules & safety'},
    "Practical Lessons": {'icon': Icons.directions, 'desc': 'Hands-on driving practice'},
    
    "Track Running": {'icon': Icons.directions_run, 'desc': 'Speed and endurance training'},
    "Marathon Prep": {'icon': Icons.directions_run, 'desc': 'Long-distance running prep'},
    "High Jump": {'icon': Icons.arrow_upward, 'desc': 'Jumping techniques'},
    "Long Jump": {'icon': Icons.arrow_forward, 'desc': 'Distance jumping skills'},
    
    "Football": {'icon': Icons.sports_soccer, 'desc': 'Football skills training'},
    "Cricket": {'icon': Icons.sports_cricket, 'desc': 'Cricket coaching'},
    "Yoga": {'icon': Icons.self_improvement, 'desc': 'Mind & body wellness'},
    "Gym": {'icon': Icons.fitness_center, 'desc': 'Strength & fitness training'},
    "Swimming": {'icon': Icons.pool, 'desc': 'Swimming techniques'},
    
    "Cooking": {'icon': Icons.restaurant, 'desc': 'Cooking fundamentals'},
    "Sewing": {'icon': Icons.content_cut, 'desc': 'Stitching & tailoring'},
    "Home Management": {'icon': Icons.home, 'desc': 'Household management'},
    "Interior Design": {'icon': Icons.architecture, 'desc': 'Interior design basics'},
    
    "Music Production": {'icon': Icons.music_note, 'desc': 'Create and mix music'},
    "Creative Writing": {'icon': Icons.edit, 'desc': 'Writing & storytelling'},
    "Photography": {'icon': Icons.camera_alt, 'desc': 'Photography skills'},
    "Film Making": {'icon': Icons.videocam, 'desc': 'Film creation basics'},
  };

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
        if (nextPage >= _bannerAds.length) {
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

  // Function to generate default sections based on category
  List<Map<String, dynamic>> _getDefaultSectionsForCategory() {
    switch (widget.categoryTitle) {
      case 'Fine Arts':
        return [
          {
            'title': 'Fine Arts Skills',
            'items': [
              'Basic Drawing & Sketching',
              'Creative Art & Imagination Drawing',
              'Thematic & Subject Drawing',
              'Professional Art Techniques',
              'Art for School & Hobby',
            ],
          },
        ];
      case 'Driving Class':
        return [
          {
            'title': 'Driving Skills',
            'items': [
              'Two Wheeler',
              'Four Wheeler',
              'Heavy Vehicle',
              'Driving Rules',
              'Practical Lessons',
            ],
          },
        ];
      case 'Athlete':
        return [
          {
            'title': 'Athletics Skills',
            'items': [
              'Track Running',
              'Marathon Prep',
              'High Jump',
              'Long Jump',
            ],
          },
        ];
      case 'Sports & Fitness':
        return [
          {
            'title': 'Sports & Fitness',
            'items': [
              'Football',
              'Cricket',
              'Yoga',
              'Gym',
              'Swimming',
            ],
          },
        ];
      case 'Home Science':
        return [
          {
            'title': 'Home Science Skills',
            'items': [
              'Cooking',
              'Sewing',
              'Home Management',
              'Interior Design',
            ],
          },
        ];
      case 'Other Classes':
        return [
          {
            'title': 'Other Skills',
            'items': [
              'Music Production',
              'Creative Writing',
              'Photography',
              'Film Making',
            ],
          },
        ];
      default:
        return [
          {
            'title': 'Skills',
            'items': [
              'Skill 1',
              'Skill 2',
              'Skill 3',
              'Skill 4',
              'Skill 5',
            ],
          },
        ];
    }
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
    
    // Card dimensions
    final double cardWidth = (screenWidth - (horizontalPadding * 2) - 
                            (_responsiveValue(12, 16, 20) * (numColumns - 1))) / numColumns;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
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
                        size: _responsiveValue(24, 26, 28),
                        color: Colors.white,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.categoryTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 22, 24),
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
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== BANNER CAROUSEL =====
                        Padding(
                          padding: EdgeInsets.only(
                            top: _responsiveValue(16, 20, 24),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: _responsiveValue(200, 280, 300),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _bannerAds.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: horizontalPadding,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(_bannerAds[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // Dots Indicator
                              SizedBox(height: _responsiveValue(12, 16, 20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _bannerAds.asMap().entries.map((entry) {
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
                            ],
                          ),
                        ),

                        // ===== SECTIONS =====
                        // Use _displaySections instead of widget.sections
                        ..._displaySections.asMap().entries.map((sectionEntry) {
                          final sectionIndex = sectionEntry.key;
                          final section = sectionEntry.value;
                          
                          return Column(
                            children: [
                              // Section Header
                              Container(
                                margin: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCFE5FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: _responsiveValue(16, 18, 20),
                                  horizontal: _responsiveValue(20, 24, 28),
                                ),
                                child: Center(
                                  child: Text(
                                    section['title'] as String,
                                    style: TextStyle(
                                      fontSize: _responsiveValue(18, 20, 22),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0B5AA7),
                                    ),
                                  ),
                                ),
                              ),

                              // Skill Cards Grid
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: _responsiveValue(8, 12, 16),
                                ),
                                child: Wrap(
                                  spacing: _responsiveValue(12, 16, 20),
                                  runSpacing: _responsiveValue(12, 16, 20),
                                  children: (section['items'] as List).map((item) {
                                    final itemStr = item as String;
                                    final meta = _skillMeta[itemStr] ?? {
                                      'icon': Icons.book,
                                      'desc': 'Explore this skill',
                                    };
                                    
                                    return _buildSkillCard(
                                      title: itemStr,
                                      icon: meta['icon'] as IconData,
                                      description: meta['desc'] as String,
                                      width: cardWidth,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),

                        // ===== YOUTUBE VIDEO SECTION - UPDATED LIKE EXAM1 =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(20, 30, 40),
                            bottom: 0, // Reduced bottom margin
                          ),
                          width: double.infinity,
                          height: isDesktop ? 360 : (isTablet ? 280 : 220), // Same height as Exam1
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

                        // Footer Spacer
                       // SizedBox(height: _responsiveValue(100, 120, 140)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required IconData icon,
    required String description,
    required double width,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Extraskills3Screen(
              skillTitle: title,
              skillDescription: description,
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
              // Icon Container
              Container(
                width: _responsiveValue(56, 64, 72),
                height: _responsiveValue(56, 64, 72),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2295D2), Color(0xFF284598)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_responsiveValue(12, 14, 16)),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: _responsiveValue(28, 32, 36),
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: _responsiveValue(12, 14, 16)),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 17, 18),
                  fontWeight: FontWeight.w700,
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
                description,
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
        content: Text('Would you like to open: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: $url')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}