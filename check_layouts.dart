import 'dart:io';

void main() {
  var files = [
    'lib/pages/Tutions/Tutions3.dart',
    'lib/pages/Jobs/Jobs4.dart',
    'lib/pages/Jobs/Jobs3.dart',
    'lib/pages/Jobs/Jobs2.dart',
    'lib/pages/Extraskills/Extraskills4.dart',
    'lib/pages/Extraskills/Extraskills1.dart',
    'lib/pages/College/College5.dart',
    'lib/pages/College/College4.dart',
    'lib/pages/College/College2.dart',
    'lib/pages/College/College3.dart',
    'lib/pages/College/College1.dart',
    'lib/pages/Blogs/BlogDetailsScreen.dart',
    'lib/pages/Blogs/BlogsScreen.dart'
  ];

  for (var path in files) {
    try {
      var content = File(path).readAsStringSync();
      if (content.contains('CustomScrollView')) {
        print('\$path uses CustomScrollView');
      } else if (content.contains('SingleChildScrollView')) {
        print('\$path uses SingleChildScrollView');
      } else {
        print('\$path uses something else');
      }
    } catch (e) {
      print('Error \$path: \$e');
    }
  }
}
