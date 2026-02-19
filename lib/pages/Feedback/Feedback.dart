// lib/pages/Feedback/Feedback.dart
import 'package:flutter/material.dart';
import '../../widgets/Footer.dart'; // Import your footer

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Customer Feedback Data
  final List<Map<String, dynamic>> _feedbacks = [
    {
      'id': 1,
      'name': 'Mabisha',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'rating': 5,
      'comment':
          'The service was excellent! Very friendly staff and quick response. Highly recommended.',
    },
    {
      'id': 2,
      'name': 'Arun Kumar',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'rating': 4,
      'comment':
          'Good experience overall. The booking process was simple, but can improve in speed.',
    },
    {
      'id': 3,
      'name': 'Priya Sharma',
      'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      'rating': 5,
      'comment':
          'Amazing app! Saved me so much time waiting in queues. Will definitely use it again.',
    },
    {
      'id': 4,
      'name': 'Rahul Mehta',
      'avatar': 'https://randomuser.me/api/portraits/men/54.jpg',
      'rating': 3,
      'comment':
          'The app is helpful but sometimes notifications are delayed. Please fix this.',
    },
    {
      'id': 5,
      'name': 'Divya Patel',
      'avatar': 'https://randomuser.me/api/portraits/women/12.jpg',
      'rating': 5,
      'comment':
          'Fantastic experience! User-friendly design and smooth booking process.',
    },
  ];

  // Responsive value function
  double _responsiveValue(double mobile, double tablet, double desktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1024) return desktop; // Desktop
    if (screenWidth >= 768) return tablet; // Tablet
    return mobile; // Mobile
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Handle form submission
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _commentController.text.isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and give a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add new feedback to the list
    setState(() {
      _feedbacks.insert(0, {
        'id': _feedbacks.length + 1,
        'name': _nameController.text,
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg', // Default
        'rating': _rating,
        'comment': _commentController.text,
      });
    });

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _commentController.clear();
    setState(() {
      _rating = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSave() {
    // Handle save draft functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback saved as draft'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: const Color(0xFF0077B6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _responsiveValue(16, 24, 32),
                vertical: _responsiveValue(16, 20, 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feedback Form
                  _buildFeedbackForm(),

                  // Customer Feedback Section
                  _buildCustomerFeedbackSection(isTablet),
                ],
              ),
            ),
          ),

          // Footer
          const Footer(
            currentIndex: 2, // Feedback is index 2
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_responsiveValue(16, 20, 24)),
      decoration: BoxDecoration(
        color: const Color(0xFFCFE8F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Title
          Center(
            child: Text(
              'Feedback Form',
              style: TextStyle(
                fontSize: _responsiveValue(18, 20, 22),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0077B6),
              ),
            ),
          ),
          SizedBox(height: _responsiveValue(16, 20, 24)),

          // Student Name Field
          Text(
            'Student Name',
            style: TextStyle(
              fontSize: _responsiveValue(14, 15, 16),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _responsiveValue(4, 6, 8)),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              contentPadding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
            ),
          ),
          SizedBox(height: _responsiveValue(12, 16, 20)),

          // Email Field
          Text(
            'Email ID',
            style: TextStyle(
              fontSize: _responsiveValue(14, 15, 16),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _responsiveValue(4, 6, 8)),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              contentPadding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
            ),
          ),
          SizedBox(height: _responsiveValue(12, 16, 20)),

          // Rating Section
          Row(
            children: [
              Text(
                'Rate :',
                style: TextStyle(
                  fontSize: _responsiveValue(14, 15, 16),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: _responsiveValue(10, 12, 14)),
              _buildRatingStars(),
            ],
          ),
          SizedBox(height: _responsiveValue(12, 16, 20)),

          // Comment Field
          Text(
            'Comment / Query',
            style: TextStyle(
              fontSize: _responsiveValue(14, 15, 16),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _responsiveValue(4, 6, 8)),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              contentPadding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
            ),
          ),
          SizedBox(height: _responsiveValue(16, 20, 24)),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Send Button
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: _responsiveValue(8, 10, 12)),
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      padding: EdgeInsets.symmetric(
                        vertical: _responsiveValue(12, 14, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontSize: _responsiveValue(14, 15, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Save Button
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: _responsiveValue(8, 10, 12)),
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      padding: EdgeInsets.symmetric(
                        vertical: _responsiveValue(12, 14, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: _responsiveValue(14, 15, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starIndex;
            });
          },
          child: Icon(
            starIndex <= _rating ? Icons.star : Icons.star_border,
            size: _responsiveValue(24, 28, 32),
            color: const Color(0xFFF4C430),
          ),
        );
      }),
    );
  }

  Widget _buildCustomerFeedbackSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _responsiveValue(24, 28, 32)),
        Text(
          'Customer Feedback',
          style: TextStyle(
            fontSize: _responsiveValue(16, 18, 20),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0077B6),
          ),
        ),
        SizedBox(height: _responsiveValue(12, 16, 20)),

        // Horizontal scroll for mobile, Grid for tablet/desktop
        if (isTablet)
          _buildFeedbackGrid()
        else
          _buildFeedbackHorizontalScroll(),
      ],
    );
  }

  Widget _buildFeedbackHorizontalScroll() {
    return SizedBox(
      height: _responsiveValue(180, 200, 220),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final feedback = _feedbacks[index];
          return Container(
            width: _responsiveValue(200, 220, 240),
            margin: EdgeInsets.only(
              right: index < _feedbacks.length - 1
                  ? _responsiveValue(12, 16, 20)
                  : 0,
            ),
            child: _buildFeedbackCard(feedback),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackGrid() {
    final crossAxisCount = MediaQuery.of(context).size.width >= 1024 ? 3 : 2;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _responsiveValue(12, 16, 20),
        mainAxisSpacing: _responsiveValue(12, 16, 20),
        childAspectRatio: 0.8,
      ),
      itemCount: _feedbacks.length,
      itemBuilder: (context, index) {
        return _buildFeedbackCard(_feedbacks[index]);
      },
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0077B6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(_responsiveValue(12, 14, 16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: _responsiveValue(50, 55, 60),
            height: _responsiveValue(50, 55, 60),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(feedback['avatar'] as String),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          SizedBox(height: _responsiveValue(8, 10, 12)),

          // Name
          Text(
            feedback['name'] as String,
            style: TextStyle(
              fontSize: _responsiveValue(14, 15, 16),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: _responsiveValue(6, 8, 10)),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < feedback['rating'] ? Icons.star : Icons.star_border,
                size: _responsiveValue(14, 16, 18),
                color: const Color(0xFFFFD700),
              );
            }),
          ),
          SizedBox(height: _responsiveValue(8, 10, 12)),

          // Comment
          Expanded(
            child: Text(
              feedback['comment'] as String,
              style: TextStyle(
                fontSize: _responsiveValue(12, 13, 14),
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}