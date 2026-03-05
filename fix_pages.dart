import 'dart:io';

void main() {
  final directory = Directory('lib/pages');
  if (!directory.existsSync()) {
    print('Directory not found');
    return;
  }

  int filesModified = 0;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      bool changed = false;
      String content = entity.readAsStringSync();
      // Normalize line endings to LF
      content = content.replaceAll('\r\n', '\n');

      if (content.contains('backgroundColor: Colors.white,')) {
        content = content.replaceAll(
          '    return Scaffold(\n      backgroundColor: Colors.white,',
          '    return Scaffold(\n      backgroundColor: const Color(0xFFF4F8FF),'
        );
        content = content.replaceAll(
          '    return Scaffold(\n      backgroundColor: Colors.white ,',
          '    return Scaffold(\n      backgroundColor: const Color(0xFFF4F8FF),'
        );
      }
      
      // Also catch one-liner Scaffold(backgroundColor: Colors.white
      content = content.replaceAll('Scaffold(\n      backgroundColor: Colors.white,', 'Scaffold(\n      backgroundColor: const Color(0xFFF4F8FF),');
      content = content.replaceAll('Scaffold(backgroundColor: Colors.white,', 'Scaffold(backgroundColor: const Color(0xFFF4F8FF),');

      // Now the youtube player height
      if (content.contains('isTablet ? 280 : 220')) {
        content = content.replaceAll('isTablet ? 280 : 220', 'isTablet ? 320 : 220');
        changed = true;
      }
      if (content.contains('isTablet ? 250 : 220')) {
        content = content.replaceAll('isTablet ? 250 : 220', 'isTablet ? 320 : 220');
        changed = true;
      }
      if (content.contains('isTablet ? 320 : 250')) {
        // Just leave as 320
      }

      // Remove specific margins that create bottom gap
      if (content.contains('margin: const EdgeInsets.only(top: 16, bottom: 16)')) {
        content = content.replaceAll(
            'margin: const EdgeInsets.only(top: 16, bottom: 16)',
            'margin: const EdgeInsets.only(top: 16)');
        changed = true;
      }
      
      if (content.contains('bottom: 16,')) {
        if (!content.contains('// bottom: 16,')) {
           // careful not to replace safe stuff, but this is usually inside padding
           content = content.replaceAll('bottom: 16,', '');
           changed = true;
        }
      }
      
      if (content.contains('bottom: _responsiveValue(16, 20, 24),')) {
        content = content.replaceAll('bottom: _responsiveValue(16, 20, 24),', '');
        changed = true;
      }

      if (changed || content != entity.readAsStringSync().replaceAll('\r\n', '\n')) {
        entity.writeAsStringSync(content);
        print('Modified: \${entity.path}');
        filesModified++;
      }
    }
  }

  print('\nTotal files modified: \$filesModified');
}
