import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemTapped;

  const Footer({
    super.key,
    this.currentIndex = 0,
    this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Container(
      height: isTablet ? 80 : 70,
      decoration: BoxDecoration(
        color: const Color(0xFF003366),
        border: Border.all(color: const Color(0xFF1a73e8), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem(
            context,
            icon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildFooterItem(
            context,
            icon: Icons.search,
            label: 'Search',
            index: 1,
          ),
          _buildFooterItem(
            context,
            icon: Icons.bookmark,
            label: 'Saved',
            index: 2,
          ),
          _buildFooterItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return GestureDetector(
      onTap: () => onItemTapped?.call(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isTablet ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: isTablet ? 14 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}