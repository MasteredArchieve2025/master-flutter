import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemTapped;
  final ValueChanged<String>? onNavigation;

  const Footer({
    super.key,
    this.currentIndex = 0,
    this.onItemTapped,
    this.onNavigation,
  });

  static const List<Map<String, dynamic>> icons = [
    {"name": Icons.home_outlined, "key": "Home", "label": "Home"},
    {"name": Icons.shopping_basket_outlined, "key": "Charity", "label": "Charity"},
    {"name": Icons.help_outline_outlined, "key": "Feedback", "label": "Feedback"},
    {"name": Icons.person_outline_outlined, "key": "Profile", "label": "Profile"},
  ];

  // NAVIGATION METHODS
  void _navigateToCharity(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != '/charity') {
      Navigator.pushNamed(context, '/charity');
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/', 
      (route) => false
    );
  }

  void _navigateToFeedback(BuildContext context) {
    Navigator.pushNamed(context, '/feedback');
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _handleNavigation(BuildContext context, String key) {
    switch (key) {
      case 'Charity':
        _navigateToCharity(context);
        break;
      case 'Home':
        _navigateToHome(context);
        break;
      case 'Feedback':
        _navigateToFeedback(context);
        break;
      case 'Profile':
        _navigateToProfile(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final bottomInset = MediaQuery.of(context).padding.bottom; // Correct variable name

    return Container(
      // ✅ FIXED: Using fromLTRB with correct variable
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16, // left
        isTablet ? 12 : 8,  // top
        isTablet ? 24 : 16, // right
        bottomInset,        // bottom - dynamic for device notches
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (index) => _buildIconButton(
            context: context,
            icon: icons[index]["name"] as IconData,
            key: icons[index]["key"] as String,
            label: icons[index]["label"] as String,
            index: index,
            isTablet: isTablet,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required String key,
    required String label,
    required int index,
    required bool isTablet,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        onItemTapped?.call(index);
        onNavigation?.call(key);
        _handleNavigation(context, key);
      },
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: 'Go to $label screen',
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 8 : 6,
          ),
          child: Icon(
            icon,
            size: isTablet ? 32 : 28,
            color: isSelected 
                ? const Color(0xFF07448A) 
                : const Color(0xFF07448A).withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}