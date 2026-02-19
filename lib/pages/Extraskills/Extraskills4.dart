// lib/pages/Extraskills/Extraskills4.dart
import 'package:flutter/material.dart';
import '../../widgets/footer.dart';

class Extraskills4Screen extends StatefulWidget {
  final Map<String, dynamic> studio;

  const Extraskills4Screen({
    super.key,
    required this.studio,
  });

  @override
  State<Extraskills4Screen> createState() => _Extraskills4ScreenState();
}
class _Extraskills4ScreenState extends State<Extraskills4Screen> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Student',
      'rating': 5,
      'comment': 'Great studio with professional trainers!',
    },
  ];

  // Banner Ads
  final List<String> _bannerAds = [
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&h=400&fit=crop",
    "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&h=400&fit=crop",
  ];

  // Gallery Images
  final List<String> _galleryImages = [
    'assets/ExSkGallery.png',
    'assets/ExSkGallery2.png',
    'assets/ExSkGallery.png',
    'assets/ExSkGallery2.png',
  ];

  // Studio Offers
  final List<String> _studioOffers = [
    'Bharatanatyam',
    'Western Dance',
    'Zumba',
    'Fitness',
    'Contemporary',
    'Hip Hop',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients && mounted) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= _bannerAds.length) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  void _submitReview() {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete'),
          content: const Text('Please give rating and write review'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(0, {
        'name': 'Anonymous',
        'rating': _rating,
        'comment': _reviewController.text,
      });
      _rating = 0;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleWhatsApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp'),
        content: const Text('Would open WhatsApp to: +123456789'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('WhatsApp would open here'),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _handleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call'),
        content: const Text('Would call: +123456789'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone dialer would open here'),
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _handleWebsite() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Website'),
        content: const Text('Would open: www.eMotion.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Website would open in browser'),
                ),
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
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive values
    double responsiveValue(double mobile, double tablet, double desktop) {
      if (isDesktop) return desktop;
      if (isTablet) return tablet;
      return mobile;
    }

    // Dimensions
    final double bannerHeight = responsiveValue(180, 240, 280);
    final double videoHeight = responsiveValue(200, 280, 320);
    final double heroCardHeight = responsiveValue(220, 220, 260);
    final double galleryImageSize = responsiveValue(100, 130, 160);
    final double horizontalPadding = responsiveValue(16, 20, 24);
    final double cardPadding = responsiveValue(16, 20, 24);
    final double cardRadius = responsiveValue(16, 18, 20);
    final double titleFontSize = responsiveValue(18, 20, 22);
    final double bodyFontSize = responsiveValue(14, 15, 16);
    final double smallFontSize = responsiveValue(12, 13, 14);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0052A2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                height: responsiveValue(52, 64, 72),
                child: Row(
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: responsiveValue(24, 26, 28),
                        color: Colors.white,
                      ),
                    ),
                    
                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Studio Details',
                          style: TextStyle(
                            fontSize: responsiveValue(18, 20, 22),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Placeholder for alignment
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ===== BANNER CAROUSEL =====
                  SizedBox(
                    height: bannerHeight,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: _bannerAds.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBannerIndex = index;
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
                  SizedBox(height: responsiveValue(8, 10, 12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _bannerAds.asMap().entries.map((entry) {
                      return Container(
                        width: responsiveValue(6, 7, 8),
                        height: responsiveValue(6, 7, 8),
                        margin: EdgeInsets.symmetric(
                          horizontal: responsiveValue(3, 4, 5),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentBannerIndex == entry.key
                              ? const Color(0xFF0B5ED7)
                              : Colors.grey[300],
                        ),
                      );
                    }).toList(),
                  ),

                  // ===== MAIN CONTENT =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        // ===== HERO CARD =====
                        Container(
                          width: double.infinity,
                          height: heroCardHeight,
                          margin: EdgeInsets.only(
                            top: responsiveValue(16, 20, 24),
                          ),
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C73AC),
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Studio Logo/Icon
                              Container(
                                width: responsiveValue(90, 110, 130),
                                height: responsiveValue(90, 110, 130),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Color(0xFF4C73AC),
                                ),
                              ),
                              
                              SizedBox(height: responsiveValue(12, 14, 16)),
                              
                              // Studio Name
                              Text(
                                widget.studio['name'] as String,
                                style: TextStyle(
                                  fontSize: responsiveValue(20, 22, 24),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2, // Add maxLines to prevent overflow
                                overflow: TextOverflow.ellipsis,
                                
                              ),
                              
                              SizedBox(height: responsiveValue(4, 6, 8)),
                              
                              // Tagline
                              Text(
                                'Dance · Fitness · Fine Arts',
                                style: TextStyle(
                                  fontSize: responsiveValue(13, 14, 15),
                                  color: const Color(0xFFDCE8FF),
                                ),
                              ),
                              
                              SizedBox(height: responsiveValue(8, 10, 12)),
                              
                              // Location
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: responsiveValue(16, 18, 20),
                                    color: const Color(0xFFE8F0FF),
                                  ),
                                  SizedBox(width: responsiveValue(6, 8, 10)),
                                  Text(
                                    widget.studio['location'] as String,
                                    style: TextStyle(
                                      fontSize: responsiveValue(12, 13, 14),
                                      color: const Color(0xFFE8F0FF),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ===== ABOUT STUDIO =====
                        _buildSectionCard(
                          title: 'About Studio',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'At our renowned dance school, with over 18 years of experience and a reputation for exceptional hospitality, we offer a diverse range of programs to cater to different interests and passions.',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: const Color(0xFF5F6F81),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                          topMargin: responsiveValue(16, 20, 24),
                        ),

                        // ===== WE OFFER =====
                        _buildSectionCard(
                          title: 'We Offer',
                          content: Wrap(
                            spacing: responsiveValue(8, 10, 12),
                            runSpacing: responsiveValue(8, 10, 12),
                            children: _studioOffers.map((offer) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsiveValue(12, 14, 16),
                                  vertical: responsiveValue(6, 8, 10),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  offer,
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0B5ED7),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== WEBSITE =====
                        _buildSectionCard(
                          title: 'Website',
                          content: GestureDetector(
                            onTap: _handleWebsite,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  size: responsiveValue(16, 18, 20),
                                  color: const Color(0xFF0B5ED7),
                                ),
                                SizedBox(width: responsiveValue(8, 10, 12)),
                                Text(
                                  'www.eMotion.com',
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    color: const Color(0xFF0B5ED7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== GALLERY =====
                        _buildSectionCard(
                          title: 'Gallery',
                          content: SizedBox(
                            height: galleryImageSize,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _galleryImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: galleryImageSize,
                                  height: galleryImageSize,
                                  margin: EdgeInsets.only(
                                    right: responsiveValue(10, 14, 18),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFE8F0FF),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.photo,
                                    size: 40,
                                    color: Color(0xFF4C73AC),
                                  ),
                                );
                              },
                            ),
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== ABOUT OUR MASTER =====
                        _buildSectionCard(
                          title: 'About Our Master',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mr. Ram Ranjith is a visionary artistic director and accomplished fitness instructor with over two decades of experience in dance and fine arts.',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: const Color(0xFF5F6F81),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== RATE & REVIEW =====
                        _buildSectionCard(
                          title: 'Rate & Review',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Star Rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                    },
                                    child: Icon(
                                      index < _rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: responsiveValue(32, 36, 40),
                                      color: const Color(0xFFFFD700),
                                    ),
                                  );
                                }),
                              ),
                              
                              SizedBox(height: responsiveValue(16, 20, 24)),
                              
                              // Review Input
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.all(
                                  responsiveValue(12, 14, 16),
                                ),
                                child: TextField(
                                  controller: _reviewController,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: 'Write your review...',
                                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: responsiveValue(12, 14, 16)),
                              
                              // Submit Button
                              GestureDetector(
                                onTap: _submitReview,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: responsiveValue(12, 14, 16),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B5ED7),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send,
                                        size: responsiveValue(18, 20, 22),
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: responsiveValue(8, 10, 12)),
                                      Text(
                                        'Submit Review',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== REVIEWS LIST =====
                        _buildSectionCard(
                          title: 'Reviews',
                          content: Column(
                            children: _reviews.map((review) {
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: responsiveValue(10, 12, 14),
                                ),
                                padding: EdgeInsets.all(
                                  responsiveValue(12, 14, 16),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review['name'] as String,
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0B5ED7),
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review['rating']
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: responsiveValue(14, 16, 18),
                                              color: const Color(0xFFFFD700),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: responsiveValue(6, 8, 10)),
                                    Text(
                                      review['comment'] as String,
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          padding: cardPadding,
                          radius: cardRadius,
                        ),

                        // ===== CALL & WHATSAPP =====
                        Container(
                          margin: EdgeInsets.only(
                            top: responsiveValue(16, 20, 24),
                          ),
                          child: Row(
                            children: [
                              // Call Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: _handleCall,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: responsiveValue(14, 16, 18),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE51515),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.call,
                                          size: responsiveValue(18, 20, 22),
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: responsiveValue(6, 8, 10)),
                                        Text(
                                          'Call',
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(width: responsiveValue(8, 10, 12)),
                              
                              // WhatsApp Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: _handleWhatsApp,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: responsiveValue(14, 16, 18),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          size: responsiveValue(18, 20, 22),
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: responsiveValue(6, 8, 10)),
                                        Text(
                                          'WhatsApp',
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== VIDEO SECTION =====
                        Container(
                          width: double.infinity,
                          height: videoHeight,
                          margin: EdgeInsets.only(
                            top: responsiveValue(32, 40, 48),
                            bottom: 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.black,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Studio Video',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'YouTube video would be embedded here',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Footer Spacer
                       // SizedBox(height: responsiveValue(100, 120, 140)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required double padding,
    required double radius,
    double topMargin = 0,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: topMargin,
        bottom: padding,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF004780),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}