// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/Home/Homepage.dart';
import 'pages/School/School1.dart';
import 'pages/School/School2.dart';
import 'pages/School/School3.dart';
import 'pages/Tutions/Tutions1.dart';
import 'pages/Tutions/Tutions2.dart';
import 'pages/Tutions/Tutions3.dart';
import 'pages/College/College1.dart';
import 'pages/Course/Course1.dart';
import 'pages/Exam/Exam1.dart';
import 'pages/IQ/IQ1.dart';
import 'pages/Extraskills/Extraskills1.dart';
import './pages/Charity/Charity.dart';
import './pages/Feedback/Feedback.dart';
import './pages/Profile/Profile.dart';  // REMOVE ./pages/Blogs/BlogsScreen.dart if not exists
import './pages/Blogs/BlogsScreen.dart';
import './pages/Auth/AuthLoading.dart';
import './pages/Auth/AuthScreen.dart';
import './pages/Auth/ForgotPassword.dart';

void main() {
  runApp(const MyEducationApp());
}

class MyEducationApp extends StatelessWidget {
  const MyEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arunachala College',
      theme: ThemeData(
        primaryColor: const Color(0xFF0175D3),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 10,
          ),
        ),
      ),
      initialRoute: '/loading',
      routes: {
        // Auth Routes
        '/loading': (context) => const AuthLoadingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        
        // Home Route
        '/home': (context) => const HomeScreen(),
        
        // School Routes
        '/school1': (context) => const School1Screen(),
        '/school2': (context) => const School2Screen(),
        
        // Tutions Routes
        '/tutions1': (context) => const Tution1Screen(),
        '/tutions2': (context) => Tution2Screen(selectedClass: 'Class 12'),
        '/tutions3': (context) => Tution3Screen(instituteName: 'Elite Scholars Academy'),
        
        // Other Routes
        '/college1': (context) => const College1Screen(),
        '/course1': (context) => const Course1Screen(),
        '/exam1': (context) => Exam1Screen(),
        '/iq1': (context) => const IQ1Screen(),
        '/extraskills1': (context) => const Extraskills1Screen(),
        '/charity': (context) => const CharityScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/profile': (context) => const ProfileScreen(),  // REMOVE const if ProfileScreen is not const
        '/blogs': (context) => const BlogsScreen(),
      },
      onGenerateRoute: (settings) {
        final String routeName = settings.name ?? '';
        
        switch (routeName) {
          case '/school1':
            return MaterialPageRoute(builder: (context) => const School1Screen());
          case '/school2':
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => School2Screen(initialCategory: args),
            );
          case '/school3':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => School3Screen(school: args),
            );
          case '/tutions1':
            return MaterialPageRoute(builder: (context) => const Tution1Screen());
          case '/tutions2':
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => Tution2Screen(
                selectedClass: args ?? 'Class 12',
              ),
            );
          case '/tutions3':
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => Tution3Screen(
                instituteName: args ?? 'Elite Scholars Academy',
              ),
            );
          case '/college1':
            return MaterialPageRoute(builder: (context) => const College1Screen());
          case '/course1':
            return MaterialPageRoute(builder: (context) => const Course1Screen());
          case '/exam1':
            return MaterialPageRoute(builder: (context) => const Exam1Screen());
          case '/iq1':
            return MaterialPageRoute(builder: (context) => const IQ1Screen());
          case '/extraskills1':
            return MaterialPageRoute(builder: (context) => const Extraskills1Screen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/charity':
            return MaterialPageRoute(builder: (context) => const CharityScreen());
          case '/feedback':
            return MaterialPageRoute(builder: (context) => const FeedbackScreen());
          case '/profile':
            return MaterialPageRoute(builder: (context) => const ProfileScreen());  // REMOVE const if needed
          case '/blogs':
            return MaterialPageRoute(builder: (context) => const BlogsScreen());
          case '/auth':
            return MaterialPageRoute(builder: (context) => const AuthScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());
          case '/loading':
            return MaterialPageRoute(builder: (context) => const AuthLoadingScreen());
          default:
            return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}