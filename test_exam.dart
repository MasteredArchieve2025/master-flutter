import 'dart:io';

void main() {
  final directory = Directory('lib/pages/Exam');
  if (!directory.existsSync()) {
    print('Directory not found');
    return;
  }

  int filesModified = 0;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      bool changed = false;
      String content = entity.readAsStringSync();
      content = content.replaceAll('\r\n', '\n');

      if (!content.contains('CommonYoutubePlayer')) {
        continue;
      }
      if (content.contains('child: LayoutBuilder(') && content.contains('child: IntrinsicHeight(')) {
        continue;
      }

      // Instead of huge regex, let's locate the `SingleChildScrollView` that comes right after `// ===== MAIN CONTENT =====` or similar
      String marker = '// ===== MAIN CONTENT =====';
      String alternativeMarker = 'child: _isLoading';
      
      int markerPos = content.indexOf(marker);
      if (markerPos == -1) {
         markerPos = content.indexOf(alternativeMarker);
      }
      
      if (markerPos != -1) {
        int scrollPos = content.indexOf('SingleChildScrollView(', markerPos);
        if (scrollPos != -1 && scrollPos < markerPos + 2000) {
           // Find the `children: [` that follows it
           int childrenPos = content.indexOf('children: [', scrollPos);
           if (childrenPos != -1 && childrenPos < scrollPos + 500) {
              // Extract the exact string from `SingleChildScrollView(` to `children: [`
              String targetStr = content.substring(scrollPos, childrenPos + 11);
              
              String replacementStr = 'LayoutBuilder(\n'
                  '                              builder: (context, constraints) {\n'
                  '                                return ' + 
                  targetStr.replaceFirst('SingleChildScrollView(', 'SingleChildScrollView(\n                                  physics: const BouncingScrollPhysics(),') 
                  // But we must wrap the Center in IntrinsicHeight... this is tricky because Center is inside SingleChildScrollView.
                  // Let's manually replace targetStr:
                  ;
                  
              // Wait, instead of this string manipulation, let's use exact strings.
              print('Found match in \${entity.path}');
           }
        }
      }
    }
  }
}
