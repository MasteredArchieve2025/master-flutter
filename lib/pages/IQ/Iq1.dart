// lib/pages/IQ/IQ1.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';
import 'IQ2.dart'; // Add this import

class IQ1Screen extends StatefulWidget {
  const IQ1Screen({super.key});

  @override
  State<IQ1Screen> createState() => _IQ1ScreenState();
}

class _IQ1ScreenState extends State<IQ1Screen> {
  // Dummy image URLs - replace with your actual images
  final List<String> cardImages = [
    "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1589256469067-ea99122bbdc4?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=400&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400&h=400&fit=crop",
  ];

  // Test categories data
  final List<Map<String, dynamic>> testCategories = [
    {
      'id': 1,
      'title': 'Brain IQ test',
      'image': '',
      'color': [Color(0xFF0072BC), Color(0xFF0052A2)],
    },
    {
      'id': 2,
      'title': 'Logical Reasoning',
      'image': '',
      'color': [Color(0xFF00C9FF), Color(0xFF0072BC)],
    },
    {
      'id': 3,
      'title': 'Mathematical Reasoning',
      'image': '',
      'color': [Color(0xFFFF416C), Color(0xFFFF4B2B)],
    },
    {
      'id': 4,
      'title': 'Spatial ability',
      'image': '',
      'color': [Color(0xFF7F00FF), Color(0xFFE100FF)],
    },
    {
      'id': 5,
      'title': 'Verbal Ability',
      'image': '',
      'color': [Color(0xFF00B09B), Color(0xFF96C93D)],
    },
    {
      'id': 6,
      'title': 'Memory Test',
      'image': '',
      'color': [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    },
  ];

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

  // Show URL dialog
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Video'),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;
    
    // Calculate card size for 2-column grid
    final double cardMargin = _responsiveValue(15, 20, 25);
    final double cardWidth = (screenWidth - cardMargin * 3) / 2;
    final double cardHeight = cardWidth; // Square cards
    
    // Responsive values
    final double horizontalPadding = _responsiveValue(16, 24, 32);
    final double maxContentWidth = isDesktop ? 1200 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: _responsiveValue(52, 58, 64),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      width: _scale(40),
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: _scale(24),
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
                          'IQ Test',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _responsiveValue(17, 18, 19),
                            fontWeight: FontWeight.w600,
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
                        SizedBox(height: _scale(20)),

                        // ===== TOP BANNER =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: cardMargin),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0072BC), Color(0xFF0052A2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(_scale(12)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0072BC).withOpacity(0.25),
                                blurRadius: _scale(6),
                                offset: Offset(0, _scale(2)),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(_scale(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Measure Your Intelligence',
                                style: TextStyle(
                                  fontSize: _responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: _scale(5)),
                              Text(
                                'Complete tests to get your comprehensive IQ score',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _scale(20)),

                        // ===== SECTION HEADER =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: cardMargin),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Choose Test Type',
                                style: TextStyle(
                                  fontSize: _responsiveValue(18, 19, 20),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF003366),
                                ),
                              ),
                              Text(
                                '6 tests available',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _scale(15)),

                        // ===== GRID CONTAINER - 2 COLUMNS =====
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: cardMargin),
                          child: Wrap(
                            spacing: cardMargin,
                            runSpacing: cardMargin,
                            children: testCategories.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final Map<String, dynamic> category = entry.value;
                              final imageIndex = index % cardImages.length;
                              
                              return GestureDetector(
                                onTap: () {
                                  if (category['title'] == 'Brain IQ test') {
                                    // Navigate to IQ2 screen
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => IQ2Screen(),
                                       ),
                                     );
                                  }
                                },
                                child: Container(
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(_scale(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: _scale(8),
                                        offset: Offset(0, _scale(4)),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Card Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(_scale(16)),
                                        child: Image.network(
                                          cardImages[imageIndex],
                                          width: cardWidth,
                                          height: cardHeight,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: cardWidth,
                                              height: cardHeight,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: (category['color'] as List<Color>),
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: cardWidth,
                                              height: cardHeight,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: (category['color'] as List<Color>),
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      
                                      // Dark Overlay Gradient
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(_scale(16)),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.7),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            stops: const [0.5, 1.0],
                                          ),
                                        ),
                                      ),
                                      
                                      // Card Title
                                      Positioned(
                                        bottom: _scale(12),
                                        left: _scale(12),
                                        right: _scale(12),
                                        child: Text(
                                          category['title'],
                                          style: TextStyle(
                                            fontSize: _responsiveValue(16, 17, 18),
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.75),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      // Card Badge
                                      Positioned(
                                        top: _scale(12),
                                        right: _scale(12),
                                        child: Container(
                                          width: _scale(28),
                                          height: _scale(28),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0052A2).withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(_scale(14)),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: _scale(1.5),
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: _scale(12),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // ===== PROGRESS SECTION =====
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: cardMargin,
                            vertical: _scale(20),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_scale(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: _scale(4),
                                offset: Offset(0, _scale(2)),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(_scale(20)),
                          child: Column(
                            children: [
                              // Progress Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Progress',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(16, 17, 18),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF003366),
                                    ),
                                  ),
                                  Text(
                                    '0%',
                                    style: TextStyle(
                                      fontSize: _responsiveValue(16, 17, 18),
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0072BC),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: _scale(12)),
                              
                              // Progress Bar
                              Container(
                                height: _scale(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9ECEF),
                                  borderRadius: BorderRadius.circular(_scale(4)),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: 0.0, // 0% progress initially
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0072BC),
                                      borderRadius: BorderRadius.circular(_scale(4)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: _scale(8)),
                              
                              // Progress Text
                              Text(
                                '0 of 6 tests completed',
                                style: TextStyle(
                                  fontSize: _responsiveValue(14, 15, 16),
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== YOUTUBE VIDEO SECTION - LIKE EXAM1 & EXAM2 =====
                        Container(
                          margin: EdgeInsets.only(
                            top: _responsiveValue(20, 30, 40),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }
}