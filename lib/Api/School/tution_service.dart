import 'dart:convert';
import 'package:http/http.dart' as http;
import '../baseurl.dart';

class TutionService {
  static String get baseUrl => '${BaseUrl.baseUrl}/api';
  
  static final TutionService _instance = TutionService._internal();
  factory TutionService() => _instance;
  TutionService._internal();

  Future<List<dynamic>> fetchTuitions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tuitions'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception('Failed to load tuitions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tuitions: $e');
    }
  }
}

class Tution {
  final int id;
  final String tuitionName;
  final String? tuitionImage;
  final List<String> category;
  final String shortDescription;
  final double rating;
  final String result;
  final String location;
  final List<String> subjectsOffered;
  final List<String> teachingMode;
  final String about;
  final String? mapLink;
  final String mobileNumber;
  final String whatsappNumber;
  final List<String> gallery;

  Tution({
    required this.id,
    required this.tuitionName,
    this.tuitionImage,
    required this.category,
    required this.shortDescription,
    required this.rating,
    required this.result,
    required this.location,
    required this.subjectsOffered,
    required this.teachingMode,
    required this.about,
    this.mapLink,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.gallery,
  });

  factory Tution.fromJson(Map<String, dynamic> json) {
    return Tution(
      id: json['id'] ?? 0,
      tuitionName: json['tuitionName'] ?? '',
      tuitionImage: json['tuitionImage'],
      category: json['category'] != null 
          ? List<String>.from(json['category']).map((e) => e.toUpperCase()).toList() 
          : [],
      shortDescription: json['shortDescription'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      result: json['result'] ?? '',
      location: json['location'] ?? '',
      subjectsOffered: json['subjectsOffered'] != null 
          ? List<String>.from(json['subjectsOffered']) 
          : [],
      teachingMode: json['teachingMode'] != null 
          ? List<String>.from(json['teachingMode']) 
          : [],
      about: json['about'] ?? '',
      mapLink: json['mapLink'],
      mobileNumber: json['mobileNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      gallery: json['gallery'] != null 
          ? List<String>.from(json['gallery']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tuitionName': tuitionName,
      'tuitionImage': tuitionImage,
      'category': category,
      'shortDescription': shortDescription,
      'rating': rating,
      'result': result,
      'location': location,
      'subjectsOffered': subjectsOffered,
      'teachingMode': teachingMode,
      'about': about,
      'mapLink': mapLink,
      'mobileNumber': mobileNumber,
      'whatsappNumber': whatsappNumber,
      'gallery': gallery,
    };
  }
}
