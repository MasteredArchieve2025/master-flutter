// lib/pages/Institute/InstituteDetails.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/footer.dart';

class InstituteDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? institution;
  
  const InstituteDetailsScreen({
    super.key,
    this.institution,
  });

  @override
  State<InstituteDetailsScreen> createState() => _InstituteDetailsScreenState();
}

class _InstituteDetailsScreenState extends State<InstituteDetailsScreen> {
  int _activeAdIndex = 0;
  final PageController _adController = PageController();
  Timer? _adTimer;

  // Advertisement banners data
  final List<Map<String, dynamic>> ads = [
    {
      'id': '1',
      'title': 'Premium Education Facilities',
      'description': 'State-of-the-art infrastructure for better learning',
      'color': Color(0xFF4A90E2),
    },
    {
      'id': '2',
      'title': 'Expert Faculty Members',
      'description': 'Learn from industry professionals and experienced educators',
      'color': Color(0xFF50C878),
    },
    {
      'id': '3',
      'title': 'Modern Campus Facilities',
      'description': 'Advanced labs, libraries, and sports amenities',
      'color': Color(0xFFFF6B6B),
    },
  ];

  // Sample institution data
  final Map<String, dynamic> institution = {
    'name': 'Horizon International School',
    'type': 'Private Institution',
    'rating': 4.5,
    'area': 'Central District',
    'district': 'Chennai',
    'established': '1995',
    'description': 'A premier educational institution offering quality education with modern facilities and experienced faculty. We focus on holistic development of students through academics, sports, and extracurricular activities.',
    'students': '2,500+',
    'courses': '15+',
    'features': ['Smart Classes', 'Sports Academy', 'STEM Labs', 'Career Counseling', 'Language Labs'],
    'facilities': ['Wi-Fi Campus', 'Computer Lab', 'Library', 'Sports Complex', 'Science Labs', 'Cafeteria', 'Medical Room', 'Transport'],
    'contact': {
      'phone': '+91 98765 43210',
      'email': 'info@horizon.edu',
      'website': 'www.horizon.edu',
    }
  };

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
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    super.dispose();
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

  // Build star ratings
  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(
          Icons.star,
          size: _scale(16),
          color: const Color(0xFFFFD700),
        ));
      } else {
        stars.add(Icon(
          Icons.star_border,
          size: _scale(16),
          color: const Color(0xFFFFD700),
        ));
      }
    }
    
    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double adHeight = _responsiveValue(200, 240, 260);
    final double videoHeight = _responsiveValue(220, 280, 320);
    final double logoSize = _responsiveValue(80, 100, 120);
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
                          'Institute Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(18, 20, 22),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Home Button
                    IconButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      icon: Icon(
                        Icons.home_outlined,
                        size: _scale(24),
                        color: Colors.white,
                      ),
                    ),
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
                        SizedBox(
                          width: screenWidth,
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
                                      content: Text('This ad would open: ${ad['description']}'),
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
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (ad['color'] as Color).withOpacity(0.9),
                                        (ad['color'] as Color).withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Content
                                      Padding(
                                        padding: EdgeInsets.all(horizontalPadding),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: _scale(8),
                                                vertical: _scale(4),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.3),
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
                                            SizedBox(height: _scale(12)),
                                            Text(
                                              ad['title'] as String,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: _responsiveValue(18, 20, 22),
                                                fontWeight: FontWeight.w700,
                                                height: 1.2,
                                              ),
                                            ),
                                            SizedBox(height: _scale(8)),
                                            Text(
                                              ad['description'] as String,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: _responsiveValue(14, 15, 16),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                                    ? const Color(0xFF0B5ED7) 
                                    : const Color(0xFFCCCCCC),
                                  borderRadius: BorderRadius.circular(_scale(4)),
                                ),
                              );
                            }),
                          ),
                        ),

                        // ===== INSTITUTE HEADER =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_scale(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: _scale(8),
                                offset: Offset(0, _scale(4)),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo Placeholder
                              Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(_scale(12)),
                                  border: Border.all(
                                    color: const Color(0xFF4A90E2).withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: _scale(40),
                                  color: const Color(0xFF4A90E2),
                                ),
                              ),
                              SizedBox(width: _scale(16)),
                              // Title and Info - FIXED: Made this scrollable for long names
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // FIXED: Made title scrollable horizontally
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        institution['name'],
                                        style: TextStyle(
                                          fontSize: _responsiveValue(20, 22, 24),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF003366),
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: _scale(8)),
                                    // FIXED: Adjusted layout for mobile
                                    if (isMobile) ...[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _scale(12),
                                              vertical: _scale(6),
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(_scale(6)),
                                            ),
                                            child: Text(
                                              institution['type'],
                                              style: TextStyle(
                                                fontSize: _responsiveValue(12, 13, 14),
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1565C0),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: _scale(8)),
                                          Row(
                                            children: [
                                              _buildStars(institution['rating']),
                                              SizedBox(width: _scale(8)),
                                              Text(
                                                '${institution['rating']}/5',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(14, 16, 18),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF666666),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Type Badge
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _scale(12),
                                              vertical: _scale(6),
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(_scale(6)),
                                            ),
                                            child: Text(
                                              institution['type'],
                                              style: TextStyle(
                                                fontSize: _responsiveValue(12, 13, 14),
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1565C0),
                                              ),
                                            ),
                                          ),
                                          // Rating
                                          Row(
                                            children: [
                                              _buildStars(institution['rating']),
                                              SizedBox(width: _scale(8)),
                                              Text(
                                                '${institution['rating']}/5',
                                                style: TextStyle(
                                                  fontSize: _responsiveValue(14, 16, 18),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF666666),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== LOCATION DETAILS =====
                        _buildSectionCard(
                          icon: Icons.location_pin,
                          title: 'Location Details',
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.location_city,
                                label: 'Area',
                                value: institution['area'],
                              ),
                              SizedBox(height: _scale(12)),
                              _buildDetailRow(
                                icon: Icons.apartment,
                                label: 'District',
                                value: institution['district'],
                              ),
                              SizedBox(height: _scale(12)),
                              _buildDetailRow(
                                icon: Icons.calendar_today,
                                label: 'Established',
                                value: institution['established'],
                              ),
                            ],
                          ),
                        ),

                        // ===== ABOUT INSTITUTE =====
                        _buildSectionCard(
                          icon: Icons.info,
                          title: 'About Institute',
                          child: Text(
                            institution['description'],
                            style: TextStyle(
                              fontSize: _responsiveValue(14, 15, 16),
                              color: const Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ),

                        // ===== QUICK STATS =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Wrap(
                            spacing: _scale(12),
                            runSpacing: _scale(12),
                            children: [
                              _buildStatCard(
                                icon: Icons.people,
                                number: institution['students'],
                                label: 'Students',
                                color: Color(0xFF4A90E2),
                              ),
                              _buildStatCard(
                                icon: Icons.school,
                                number: institution['courses'],
                                label: 'Courses',
                                color: Color(0xFF50C878),
                              ),
                              _buildStatCard(
                                icon: Icons.grade,
                                number: '${institution['rating']}/5',
                                label: 'Rating',
                                color: Color(0xFFFF6B6B),
                              ),
                              _buildStatCard(
                                icon: Icons.verified,
                                number: institution['established'],
                                label: 'Established',
                                color: Color(0xFF9B59B6),
                              ),
                            ],
                          ),
                        ),

                        // ===== KEY FEATURES =====
                        _buildSectionCard(
                          icon: Icons.featured_play_list,
                          title: 'Key Features',
                          child: Column(
                            children: (institution['features'] as List).map<Widget>((feature) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: _scale(8)),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: _scale(16),
                                      color: const Color(0xFF50C878),
                                    ),
                                    SizedBox(width: _scale(12)),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: _responsiveValue(14, 15, 16),
                                          color: const Color(0xFF444444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== FACILITIES =====
                        _buildSectionCard(
                          icon: Icons.architecture,
                          title: 'Facilities',
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate number of columns based on screen width
                              int crossAxisCount;
                              if (constraints.maxWidth >= 1024) {
                                crossAxisCount = 4; // Desktop
                              } else if (constraints.maxWidth >= 768) {
                                crossAxisCount = 3; // Tablet
                              } else {
                                crossAxisCount = 2; // Mobile (2 per row)
                              }
                              
                              // Calculate item width
                              final double totalSpacing = _scale(12) * (crossAxisCount - 1);
                              final double availableWidth = constraints.maxWidth;
                              final double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
                              
                              return Wrap(
                                spacing: _scale(12),
                                runSpacing: _scale(12),
                                children: (institution['facilities'] as List).map<Widget>((facility) {
                                  return Container(
                                    width: itemWidth,
                                    padding: EdgeInsets.all(_scale(12)),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFF),
                                      borderRadius: BorderRadius.circular(_scale(10)),
                                      border: Border.all(
                                        color: const Color(0xFFE8F0FF),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Facility Icon based on type
                                        Container(
                                          width: _scale(36),
                                          height: _scale(36),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F7FF),
                                            borderRadius: BorderRadius.circular(_scale(18)),
                                          ),
                                          child: Center(
                                            child: _getFacilityIcon(facility),
                                          ),
                                        ),
                                        SizedBox(height: _scale(8)),
                                        Text(
                                          facility,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: _responsiveValue(11, 12, 13),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF003366),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // ===== CONTACT INFORMATION =====
                        _buildSectionCard(
                          icon: Icons.contact_phone,
                          title: 'Contact Information',
                          child: Column(
                            children: [
                              _buildContactItem(
                                icon: Icons.call,
                                title: 'Phone',
                                value: institution['contact']['phone'],
                              ),
                              SizedBox(height: _scale(16)),
                              _buildContactItem(
                                icon: Icons.email,
                                title: 'Email',
                                value: institution['contact']['email'],
                              ),
                              SizedBox(height: _scale(16)),
                              _buildContactItem(
                                icon: Icons.language,
                                title: 'Website',
                                value: institution['contact']['website'],
                              ),
                              SizedBox(height: _scale(16)),
                              _buildContactItem(
                                icon: Icons.access_time,
                                title: 'Working Hours',
                                value: 'Mon-Sat: 8:00 AM - 6:00 PM',
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          margin: EdgeInsets.only(top: _responsiveValue(20, 24, 28),
                          bottom:0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Video Header
                              Row(
                                children: [
                                  Icon(
                                    Icons.play_circle_filled,
                                    color: const Color(0xFFFF0000),
                                    size: _scale(24),
                                  ),
                                  SizedBox(width: _scale(8)),
                                  Text(
                                    'Campus Tour',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(16, 18, 20),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: _responsiveValue(12, 16, 20)),

                              // Video Container
                              Container(
                                height: videoHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(_scale(12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: _scale(10),
                                      offset: Offset(0, _scale(4)),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(_scale(12)),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Campus Tour Video'),
                                          content: Text('This would play a video tour of ${institution['name']}'),
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
                                        color: Colors.black,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.play_circle_filled,
                                              size: _scale(60),
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: _scale(12)),
                                            Text(
                                              'Take a virtual tour of',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: _responsiveValue(16, 18, 20),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: _scale(8)),
                                            Text(
                                              institution['name'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: _responsiveValue(16, 18, 20),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== ACTION BUTTONS =====
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          margin: EdgeInsets.only(
                            top: _responsiveValue(24, 28, 32),
                            bottom: _responsiveValue(16, 20, 24),
                          ),
                          child: Row(
                            children: [
                              // Visit Website Button
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: _scale(8)),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Visit Website'),
                                          content: Text('This would open: ${institution['contact']['website']}'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90E2),
                                      padding: EdgeInsets.symmetric(
                                        vertical: _scale(14),
                                        horizontal: _scale(12), // Reduced padding
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(_scale(10)),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.language,
                                            size: _scale(18), // Slightly smaller icon
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: _scale(6)),
                                          Text(
                                            'Visit Website',
                                            style: TextStyle(
                                              fontSize: _responsiveValue(13, 15, 16), // Reduced font size
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Call Now Button
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: _scale(8)),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Call Now'),
                                          content: Text('This would call: ${institution['contact']['phone']}'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF50C878),
                                      padding: EdgeInsets.symmetric(
                                        vertical: _scale(14),
                                        horizontal: _scale(12), // Reduced padding
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(_scale(10)),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.call,
                                            size: _scale(18), // Slightly smaller icon
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: _scale(6)),
                                          Text(
                                            'Call Now',
                                            style: TextStyle(
                                              fontSize: _responsiveValue(13, 15, 16), // Reduced font size
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
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

                        // ===== BOTTOM SPACER =====
                        SizedBox(height: _responsiveValue(80, 100, 120)),
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

  // Helper function to get facility icon
  Widget _getFacilityIcon(String facility) {
    final lowerFacility = facility.toLowerCase();
    if (lowerFacility.contains('wifi')) {
      return Icon(Icons.wifi, size: _scale(20), color: const Color(0xFF4A90E2));
    } else if (lowerFacility.contains('computer')) {
      return Icon(Icons.computer, size: _scale(20), color: const Color(0xFF50C878));
    } else if (lowerFacility.contains('library')) {
      return Icon(Icons.library_books, size: _scale(20), color: const Color(0xFFFF6B6B));
    } else if (lowerFacility.contains('sports')) {
      return Icon(Icons.sports, size: _scale(20), color: const Color(0xFF9B59B6));
    } else if (lowerFacility.contains('science')) {
      return Icon(Icons.science, size: _scale(20), color: const Color(0xFFFFA500));
    } else if (lowerFacility.contains('cafeteria')) {
      return Icon(Icons.restaurant, size: _scale(20), color: const Color(0xFFE74C3C));
    } else if (lowerFacility.contains('medical')) {
      return Icon(Icons.medical_services, size: _scale(20), color: const Color(0xFF2ECC71));
    } else if (lowerFacility.contains('transport')) {
      return Icon(Icons.directions_bus, size: _scale(20), color: const Color(0xFFE67E22));
    } else {
      return Icon(Icons.check_circle, size: _scale(20), color: const Color(0xFF4A90E2));
    }
  }

  // Helper Widget: Section Card
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _responsiveValue(16, 24, 32),
        vertical: _responsiveValue(8, 12, 16),
      ),
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: _scale(8),
            offset: Offset(0, _scale(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                size: _scale(24),
                color: const Color(0xFF4A90E2),
              ),
              SizedBox(width: _scale(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveValue(16, 18, 20),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003366),
                ),
              ),
            ],
          ),
          SizedBox(height: _scale(20)),
          // Section Content
          child,
        ],
      ),
    );
  }

  // Helper Widget: Detail Row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: _scale(40),
          height: _scale(40),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(_scale(20)),
          ),
          child: Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF666666),
          ),
        ),
        SizedBox(width: _scale(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: _scale(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: _responsiveValue(14, 16, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget: Stat Card
  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
    required Color color,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 
             _responsiveValue(16, 24, 32) * 2 - 
             _scale(12)) / 2,
      padding: EdgeInsets.all(_scale(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_scale(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: _scale(6),
            offset: Offset(0, _scale(2)),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: _scale(28),
            color: color,
          ),
          SizedBox(height: _scale(12)),
          Text(
            number,
            style: TextStyle(
              fontSize: _responsiveValue(18, 20, 22), // Reduced font size
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003366),
            ),
          ),
          SizedBox(height: _scale(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: _responsiveValue(11, 12, 13), // Reduced font size
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Contact Item
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _scale(40),
          height: _scale(40),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(_scale(20)),
          ),
          child: Icon(
            icon,
            size: _scale(20),
            color: const Color(0xFF4A90E2),
          ),
        ),
        SizedBox(width: _scale(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: _responsiveValue(12, 13, 14),
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: _scale(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: _responsiveValue(13, 15, 16), // Reduced font size
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF003366),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}