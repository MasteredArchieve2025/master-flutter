import 'package:flutter/material.dart';
import '../../Widgets/Footer.dart';
import 'Tutions2.dart';  // Correct - they're in the same directory

// ==================== TUITION CLASSES SCREEN ====================
class Tution1Screen extends StatefulWidget {
  const Tution1Screen({super.key});

  @override
  State<Tution1Screen> createState() => _Tution1ScreenState();
}

class _Tution1ScreenState extends State<Tution1Screen> {
  int _footerIndex = 0;
  
  // Standards Data
  final List<Map<String, dynamic>> standards = [
    {"id": "1", "title": "Class 12", "subtitle": "Science, Commerce & Arts", "icon": Icons.school, "color": Color(0xFF4F46E5)},
    {"id": "2", "title": "Class 11", "subtitle": "Science, Commerce & Arts", "icon": Icons.book, "color": Color(0xFF059669)},
    {"id": "3", "title": "Class 10", "subtitle": "Secondary Education Boards", "icon": Icons.workspace_premium, "color": Color(0xFFDC2626)},
    {"id": "4", "title": "Class 9", "subtitle": "Foundation Courses", "icon": Icons.library_books, "color": Color(0xFFEA580C)},
    {"id": "5", "title": "Classes 6 - 8", "subtitle": "Middle School Curriculum", "icon": Icons.emoji_emotions, "color": Color(0xFF2563EB)},
    {"id": "6", "title": "Classes 1 - 5", "subtitle": "Primary School Curriculum", "icon": Icons.emoji_emotions_outlined, "color": Color(0xFF7C3AED)},
    {"id": "7", "title": "Competitive", "subtitle": "JEE, NEET, UPSC", "icon": Icons.emoji_events, "color": Color(0xFFDB2777)},
    {"id": "8", "title": "Language", "subtitle": "English, French, Spanish", "icon": Icons.language, "color": Color(0xFF0891B2)},
    {"id": "9", "title": "Special Needs", "subtitle": "Personalized Learning", "icon": Icons.accessibility_new, "color": Color(0xFFCA8A04)},
    {"id": "10", "title": "University", "subtitle": "Graduate & Post Graduate", "icon": Icons.business, "color": Color(0xFF475569)},
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
    final bool isLandscape = screenWidth > screenHeight;
    
    // Responsive calculations
    final int numColumns = isTablet ? (isLandscape ? 4 : 3) : 2;
    final double containerPadding = _getHorizontalPadding(context);
    final double cardSpacing = isTablet ? 16 : 12;
    final double availableWidth = screenWidth - (containerPadding * 2);
    final double cardWidth = (availableWidth - (cardSpacing * (numColumns - 1))) / numColumns;
    final double cardHeight = isTablet ? 170 : 150;
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
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
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: containerPadding,
                ),
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
                    
                    // Header Center Content
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Main Title
                          Text(
                            'Tuition Classes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _getTitleFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          // Subtitle
                          const SizedBox(height: 2),
                          Text(
                            'Find the best tutors for your grade',
                            style: TextStyle(
                              color: const Color(0xFFDCE8FF),
                              fontSize: isDesktop ? 14 : (isTablet ? 12 : 11),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ===== BANNER INFO =====
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        containerPadding,
                        isTablet ? 24 : 20,
                        containerPadding,
                        isTablet ? 24 : 20,
                      ),
                      padding: EdgeInsets.all(isTablet ? 24 : 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B5ED7).withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.search,
                              size: isTablet ? 32 : 24,
                              color: const Color(0xFF0B5ED7),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Find Your Perfect Tutor',
                                  style: TextStyle(
                                    color: const Color(0xFF1E293B),
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Select your class to discover experienced tutors and learning centers',
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: isTablet ? 16 : 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== GRID LIST =====
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: numColumns,
                        childAspectRatio: cardWidth / cardHeight,
                        mainAxisSpacing: cardSpacing,
                        crossAxisSpacing: 0,
                      ),
                      itemCount: standards.length,
                      itemBuilder: (context, index) {
                        final item = standards[index];
                        final bool isFirstInRow = index % numColumns == 0;
                        final bool isLastInRow = (index + 1) % numColumns == 0;
                        
                        return Container(
                          margin: EdgeInsets.only(
                            left: isFirstInRow ? containerPadding : 0,
                            right: isLastInRow ? containerPadding : cardSpacing,
                            bottom: cardSpacing,
                          ),
                          child: _buildCard(
                            item: item,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            isTablet: isTablet,
                          ),
                        );
                      },
                    ),
                    
                    // Spacer for Footer
                    SizedBox(height: isTablet ? 100 : 80),
                  ],
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

  Widget _buildCard({
    required Map<String, dynamic> item,
    required double cardWidth,
    required double cardHeight,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to Tutions2 screen with selected class
         Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Tution2Screen(
            selectedClass: item['title'] as String,
          ),
        ),
      );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Box
            Container(
              width: isTablet ? 64 : 52,
              height: isTablet ? 64 : 52,
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.08),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
              ),
              child: Icon(
                item['icon'] as IconData,
                size: isTablet ? 30 : 24,
                color: item['color'] as Color,
              ),
            ),
            
            SizedBox(height: isTablet ? 16 : 12),
            
            // Title - FIXED: Added constraints
            Container(
              constraints: BoxConstraints(
                maxWidth: cardWidth - (isTablet ? 40 : 32), // Account for padding
              ),
              child: Text(
                item['title'],
                style: TextStyle(
                  color: item['color'] as Color,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(height: isTablet ? 6 : 4),
            
            // Subtitle - FIXED: Added constraints and proper overflow
            Container(
              constraints: BoxConstraints(
                maxWidth: cardWidth - (isTablet ? 40 : 32),
                maxHeight: (isTablet ? 40 : 36), // Limit height
              ),
              child: Text(
                item['subtitle'],
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}