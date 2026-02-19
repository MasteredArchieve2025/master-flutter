// lib/pages/College/Collegecourse1.dart
import 'package:flutter/material.dart';
import '../../Widgets/Footer.dart';
import 'Collegecourse2.dart'; 
class Collegecourse1Screen extends StatefulWidget {
  const Collegecourse1Screen({super.key});

  @override
  State<Collegecourse1Screen> createState() => _Collegecourse1ScreenState();
}

class _Collegecourse1ScreenState extends State<Collegecourse1Screen> {
  int _footerIndex = 0;

  // Departments Data
  final List<Map<String, dynamic>> departments = [
    { 'id': '1', 'title': 'Computer Science', 'icon': Icons.laptop },
    { 'id': '2', 'title': 'Mechanical Engineering', 'icon': Icons.settings },
    { 'id': '3', 'title': 'Electrical & Electronics', 'icon': Icons.flash_on },
    { 'id': '4', 'title': 'Business Administration', 'icon': Icons.business },
    { 'id': '5', 'title': 'Biotechnology', 'icon': Icons.science },
    { 'id': '6', 'title': 'Civil Engineering', 'icon': Icons.engineering },
  ];

  // Responsive header height like IQ1
  double _getHeaderHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 64; // Desktop
    if (screenWidth >= 768) return 58; // Tablet
    return 52; // Mobile
  }

  // Responsive font size like IQ1
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 19;
    if (screenWidth >= 768) return 18;
    return 17;
  }

  // Responsive horizontal padding like IQ1
  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return 32;
    if (screenWidth >= 768) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Responsive dimensions
    final double horizontalPadding = _getHorizontalPadding(context);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;
    final int crossAxisCount = isDesktop ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER (Updated to match IQ1) =====
            Container(
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
                borderRadius: isDesktop
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                    : null,
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: _getHeaderHeight(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button - Fixed size like IQ1
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24, // Fixed size like IQ1
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    
                    // Header Title - Centered like IQ1
                    Expanded(
                      child: Center(
                        child: Text(
                          'Departments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getTitleFontSize(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer for symmetry like IQ1
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // ===== MAIN CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== TITLE SECTION =====
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? horizontalPadding : horizontalPadding,
                            vertical: isTablet ? 20 : 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skill Courses',
                                style: TextStyle(
                                  fontSize: isDesktop ? 26 : (isTablet ? 24 : 20),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              Text(
                                'Choose a department to explore certifications',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : (isTablet ? 15 : 13),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== GRID =====
                       Padding(
  padding: EdgeInsets.only(
    left: isDesktop ? horizontalPadding : horizontalPadding,
    right: isDesktop ? horizontalPadding : horizontalPadding,
    bottom: isTablet ? 40 : 30,
  ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double availableWidth = constraints.maxWidth;
                              final double spacing = isTablet ? 18 : 14;
                              final double runSpacing = isTablet ? 18 : 14;
                              final double totalSpacing = spacing * (crossAxisCount - 1);
                              final double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;
                              
                              return Wrap(
                                spacing: spacing,
                                runSpacing: runSpacing,
                                alignment: WrapAlignment.start,
                                children: departments.map((department) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: _buildDepartmentCard(
                                      department: department,
                                      isTablet: isTablet,
                                      isDesktop: isDesktop,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        // Spacer for Footer
                        SizedBox(height: isDesktop ? 50 : 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== FOOTER =====
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
      ),
    );
  }

  Widget _buildDepartmentCard({
    required Map<String, dynamic> department,
    required bool isTablet,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Collegecourse2Screen(
        department: department['title'],
      ),
    ),
  );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${department['title']}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 18 : 14),
        padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 22 : (isTablet ? 20 : 18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Box
            Container(
              width: isDesktop ? 60 : (isTablet ? 56 : 46),
              height: isDesktop ? 60 : (isTablet ? 56 : 46),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
              ),
              child: Icon(
                department['icon'] as IconData,
                size: isDesktop ? 32 : (isTablet ? 32 : 28),
                color: const Color(0xFF0B5ED7),
              ),
            ),
            
            SizedBox(height: isDesktop ? 12 : (isTablet ? 12 : 10)),
            
            // Title
            Text(
              department['title'] as String,
              style: TextStyle(
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: isDesktop ? 10 : (isTablet ? 10 : 8)),
            
            // Badge
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: isDesktop ? 16 : (isTablet ? 16 : 14),
                  color: const Color(0xFF0B5ED7),
                ),
                
                SizedBox(width: 4),
                
                Flexible(
                  child: Text(
                    'Extra Skill Courses Available',
                    style: TextStyle(
                      fontSize: isDesktop ? 13 : (isTablet ? 12 : 11),
                      color: const Color(0xFF0B5ED7),
                      fontWeight: FontWeight.w600,
                    ),
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