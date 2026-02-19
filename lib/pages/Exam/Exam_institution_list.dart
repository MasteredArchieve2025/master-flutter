// lib/pages/Institute/InstitutionsList.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/footer.dart';
import 'InstituteDetails.dart';

class InstitutionsListScreen extends StatefulWidget {
  const InstitutionsListScreen({super.key});

  @override
  State<InstitutionsListScreen> createState() => _InstitutionsListScreenState();
}

class _InstitutionsListScreenState extends State<InstitutionsListScreen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;
  String _searchQuery = '';
  String _selectedArea = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Advertisement banners data
  final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'title': 'TOP TUITION CENTER PROGRAMS',
      'subtitle': 'Build Your Career With',
      'cta': 'Apply Now',
      'color': Color(0xFF4A90E2),
    },
    {
      'id': '2',
      'title': 'Quality Education',
      'subtitle': 'Join the Best Institutions',
      'cta': 'Enroll Now',
      'color': Color(0xFF50C878),
    },
  ];

  // Available areas
  final List<String> areas = [
    'all',
    'Central Bangalore',
    'Sector 62',
    'Mathura Road',
    'RK Puram',
    'Madhapur',
    'Karol Bagh',
  ];

  // Institutions data
  final List<Map<String, dynamic>> institutionsData = [
    {
      'id': '1',
      'name': 'Horizon School',
      'area': 'Central Bangalore',
      'district': 'Bangalore Urban',
      'type': 'Private School',
    },
    {
      'id': '2',
      'name': 'National Institute of Open Schooling',
      'area': 'Sector 62',
      'district': 'Gautam Buddha Nagar',
      'type': 'Government Institute',
    },
    {
      'id': '3',
      'name': 'Delhi Public School',
      'area': 'Mathura Road',
      'district': 'South Delhi',
      'type': 'Private School',
    },
    {
      'id': '4',
      'name': 'Kendriya Vidyalaya',
      'area': 'RK Puram',
      'district': 'South West Delhi',
      'type': 'Government School',
    },
    {
      'id': '5',
      'name': 'Sri Chaitanya',
      'area': 'Madhapur',
      'district': 'Hyderabad',
      'type': 'Private Institute',
    },
    {
      'id': '6',
      'name': 'FIITJEE',
      'area': 'Karol Bagh',
      'district': 'Central Delhi',
      'type': 'Private Institute',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto scroll ads
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adController.hasClients && mounted) {
        int nextPage = _activeAdIndex + 1;
        if (nextPage >= ads.length) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // Listen to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter institutions
  List<Map<String, dynamic>> get _filteredInstitutions {
    return institutionsData.where((institute) {
      final matchesSearch = institute['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          institute['area'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          institute['district'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesArea = _selectedArea == 'all' || institute['area'] == _selectedArea;

      return matchesSearch && matchesArea;
    }).toList();
  }

  // Scale function for responsive sizing
  double _scale(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return size * 1.2; // Desktop
    if (screenWidth >= 768) return size * 1.1; // Tablet
    return size; // Mobile
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
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double adHeight = _responsiveValue(180, 300, 240);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

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
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
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
                        size: _scale(24),
                        color: Colors.white,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Institutions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 20, 22),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Spacer for symmetry
                    SizedBox(width: _scale(40)),
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
                        // ===== ADVERTISEMENT BANNER =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          padding: EdgeInsets.only(top: _responsiveValue(16, 20, 24)),
                          child: SizedBox(
                            height: adHeight,
                            child: PageView.builder(
                              controller: _adController,
                              itemCount: ads.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _activeAdIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final ad = ads[index];
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(ad['title'] as String),
                                        content: Text('This ad would open: ${ad['cta']}'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ad['color'] as Color,
                                      borderRadius: BorderRadius.circular(_scale(12)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: _scale(8),
                                          offset: Offset(0, _scale(4)),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Content
                                        Padding(
                                          padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                ad['subtitle'] as String,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: _responsiveValue(14, 15, 16),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: _scale(8)),
                                              Text(
                                                ad['title'] as String,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: _responsiveValue(18, 20, 22),
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.2,
                                                ),
                                              ),
                                              SizedBox(height: _scale(16)),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: _scale(20),
                                                  vertical: _scale(8),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(_scale(6)),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  ad['cta'] as String,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: _responsiveValue(14, 16, 18),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Ad Badge
                                        Positioned(
                                          top: _scale(12),
                                          right: _scale(12),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _scale(8),
                                              vertical: _scale(4),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(_scale(4)),
                                            ),
                                            child: Text(
                                              'AD',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: _responsiveValue(10, 12, 12),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // ===== PAGINATION DOTS =====
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F9FF),
                          ),
                          padding: EdgeInsets.symmetric(vertical: _scale(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(ads.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _activeAdIndex == index ? _scale(10) : _scale(6),
                                height: _scale(6),
                                margin: EdgeInsets.symmetric(horizontal: _scale(4)),
                                decoration: BoxDecoration(
                                  color: _activeAdIndex == index 
                                    ? const Color(0xFF4A90E2) 
                                    : const Color(0xFFCCCCCC),
                                  borderRadius: BorderRadius.circular(_scale(4)),
                                ),
                              );
                            }),
                          ),
                        ),

                        // ===== SEARCH BAR =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: _responsiveValue(16, 20, 24),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _responsiveValue(14, 16, 18),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_scale(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: _scale(6),
                                  offset: Offset(0, _scale(2)),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: _scale(20),
                                  color: const Color(0xFF666666),
                                ),
                                SizedBox(width: _scale(10)),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search institutions...',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF999999),
                                        fontSize: _responsiveValue(14, 15, 16),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontSize: _responsiveValue(14, 15, 16),
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: _scale(20),
                                      color: const Color(0xFF999999),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: _scale(36),
                                      minHeight: _scale(36),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // ===== FILTER CHIPS =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: _responsiveValue(16, 20, 24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter by Area:',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              SizedBox(height: _scale(8)),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: areas.map((area) {
                                    bool isActive = _selectedArea == area;
                                    return Container(
                                      margin: EdgeInsets.only(right: _scale(8)),
                                      child: ChoiceChip(
                                        label: Text(
                                          area == 'all' ? 'All Areas' : area,
                                          style: TextStyle(
                                            fontSize: _responsiveValue(13, 14, 15),
                                            fontWeight: FontWeight.w600,
                                            color: isActive ? Colors.white : const Color(0xFF666666),
                                          ),
                                        ),
                                        selected: isActive,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedArea = area;
                                          });
                                        },
                                        backgroundColor: const Color(0xFFF0F0F0),
                                        selectedColor: const Color(0xFF4A90E2),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: _scale(14),
                                          vertical: _scale(8),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(_scale(16)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== RESULTS COUNT =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          margin: EdgeInsets.only(bottom: _responsiveValue(12, 16, 20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_filteredInstitutions.length} Institutions Found',
                                style: TextStyle(
                                  fontSize: _responsiveValue(16, 18, 20),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              SizedBox(height: _scale(4)),
                              Text(
                                'Showing ${_selectedArea == 'all' ? 'all areas' : _selectedArea}',
                                style: TextStyle(
                                  fontSize: _responsiveValue(13, 14, 15),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== INSTITUTIONS GRID =====
                        if (_filteredInstitutions.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate responsive card width
                                double cardWidth;
                                int crossAxisCount;
                                
                                if (isDesktop) {
                                  crossAxisCount = 3;
                                  // Reduced spacing between cards
                                  cardWidth = (constraints.maxWidth - _scale(16) * (crossAxisCount - 1)) / crossAxisCount;
                                } else if (isTablet) {
                                  crossAxisCount = 2;
                                  // Reduced spacing between cards
                                  cardWidth = (constraints.maxWidth - _scale(12) * (crossAxisCount - 1)) / crossAxisCount;
                                } else {
                                  // Mobile - full width with horizontal padding
                                  cardWidth = constraints.maxWidth;
                                }
                                
                                return Wrap(
                                  alignment: WrapAlignment.center,
                                  // Reduced horizontal spacing
                                  spacing: _responsiveValue(8, 12, 16),
                                  // Reduced vertical spacing
                                  runSpacing: _responsiveValue(12, 16, 20),
                                  children: _filteredInstitutions.map((institution) {
                                    return Container(
                                      width: isMobile ? constraints.maxWidth : cardWidth,
                                      margin: isMobile 
                                        ? EdgeInsets.only(bottom: _scale(12))
                                        : EdgeInsets.zero,
                                      child: _buildInstitutionCard(institution, isMobile: isMobile, isTablet: isTablet, isDesktop: isDesktop),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          // ===== NO RESULTS =====
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: _responsiveValue(40, 50, 60),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_outlined,
                                  size: _scale(50),
                                  color: const Color(0xFFCCCCCC),
                                ),
                                SizedBox(height: _scale(16)),
                                Text(
                                  'No institutions found',
                                  style: TextStyle(
                                    fontSize: _responsiveValue(16, 18, 20),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                                SizedBox(height: _scale(8)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                  child: Text(
                                    'Try changing your search or filters',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _responsiveValue(13, 14, 15),
                                      color: const Color(0xFF999999),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ===== YOUTUBE VIDEO SECTION - LIKE EXAM1 & EXAM2 =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(40, 50, 60),
                            bottom: 0,
                          ),
                          width: double.infinity,
                          height: isDesktop ? 360 : (isTablet ? 280 : 220),
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
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Institution Video'),
                                    content: Text('This would play a video about institutions'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 0),
    );
  }

  // Build Institution Card Widget
  Widget _buildInstitutionCard(Map<String, dynamic> institution, {
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : _scale(2), // Further reduced horizontal margin
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstituteDetailsScreen(
                institution: {
                  ...institution,
                  'rating': 4.5,
                  'students': '2,500+',
                  'courses': '15+ Programs',
                  'features': ['Smart Classes', 'Sports Academy', 'STEM Labs'],
                  'established': '1995',
                  'description': 'A premier educational institution with modern facilities and experienced faculty.',
                  'contact': {
                    'phone': '+91 98765 43210',
                    'email': 'info@institution.edu',
                    'website': 'www.institution.edu',
                  },
                  'facilities': [
                    'Wi-Fi Campus',
                    'Computer Lab',
                    'Library',
                    'Sports Complex',
                    'Science Labs',
                    'Cafeteria',
                  ],
                },
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_scale(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: _scale(8),
                offset: Offset(0, _scale(2)),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(_responsiveValue(12, 14, 16)), // Reduced padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Placeholder
                Container(
                  width: _scale(45), // Slightly smaller
                  height: _scale(45), // Slightly smaller
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_scale(8)),
                    border: Border.all(
                      color: const Color(0xFF4A90E2).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.school,
                    size: _scale(22), // Slightly smaller
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                SizedBox(width: _scale(10)), // Reduced spacing

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Institution Name
                      Text(
                        institution['name'],
                        style: TextStyle(
                          fontSize: _responsiveValue(14, 15, 16), // Slightly smaller
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003366),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _scale(6)), // Reduced spacing

                      // Location Container
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Area
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: _scale(11), // Slightly smaller
                                color: const Color(0xFF4A90E2),
                              ),
                              SizedBox(width: _scale(4)), // Reduced spacing
                              Expanded(
                                child: Text(
                                  institution['area'],
                                  style: TextStyle(
                                    fontSize: _responsiveValue(11, 12, 13), // Slightly smaller
                                    color: const Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: _scale(3)), // Reduced spacing
                          // District
                          Row(
                            children: [
                              Icon(
                                Icons.apartment,
                                size: _scale(11), // Slightly smaller
                                color: const Color(0xFF50C878),
                              ),
                              SizedBox(width: _scale(4)), // Reduced spacing
                              Expanded(
                                child: Text(
                                  institution['district'],
                                  style: TextStyle(
                                    fontSize: _responsiveValue(11, 12, 13), // Slightly smaller
                                    color: const Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: _scale(6)), // Reduced spacing

                      // Type Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _scale(8), // Reduced padding
                          vertical: _scale(3), // Reduced padding
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(_scale(6)),
                        ),
                        child: Text(
                          institution['type'],
                          style: TextStyle(
                            fontSize: _responsiveValue(10, 11, 12), // Slightly smaller
                            color: const Color(0xFF4A90E2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron Icon
                Icon(
                  Icons.chevron_right,
                  size: _scale(18), // Slightly smaller
                  color: const Color(0xFF999999),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}