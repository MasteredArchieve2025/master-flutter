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
      // Normalize to LF
      content = content.replaceAll('\r\n', '\n');

      if (!content.contains('CommonYoutubePlayer')) {
        continue;
      }
      
      // If we already inserted LayoutBuilder, skip
      if (content.contains('child: LayoutBuilder(') && content.contains('child: IntrinsicHeight(')) {
        continue;
      }

      // Check if it has Expanded -> SingleChildScrollView -> Center -> Container -> Column
      final expandedRegex = RegExp(
          r'Expanded\(\s*child:\s*SingleChildScrollView\(\s*(?:physics:\s*const[^,]*,)?\s*child:\s*Center\(\s*child:\s*Container\(\s*constraints:[^\)]+\),\s*child:\s*Column\(\s*mainAxisSize:\s*MainAxisSize.(min|max),\s*children:\s*\[',
          multiLine: true);
          
      final expandedRegexNoCenter = RegExp(
          r'Expanded\(\s*child:\s*SingleChildScrollView\(\s*(?:physics:\s*const[^,]*,)?\s*child:\s*Container\(\s*constraints:[^\)]+\),\s*child:\s*Column\(\s*children:\s*\[',
          multiLine: true);

      if (expandedRegex.hasMatch(content)) {
        final match = expandedRegex.firstMatch(content)!;
        String originalHeader = match.group(0)!;
        String replacementHeader = originalHeader.replaceFirst(
            'Expanded(',
            '''Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: _contentMaxWidth ?? 1200),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: ['''
        );
        // Sometimes padding or other differences exist, but we will construct the replacement precisely:
         replacementHeader = '''Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 1200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [''';

        // Wait, what if the video starts somewhere inside?
        // We look for:
        String videoPattern = r'if \([_]?youtubeUrls\.isNotEmpty\) \.\.\.\[';
        String videoPatternFallback = r'// ===== YOUTUBE VIDEO';
        String videoPatternFallback2 = r'child: CommonYoutubePlayer\(';

        int headerEnd = match.end;
        int videoMatchIndex = -1;
        String videoStr = '';
        
        // Find where the video section starts
        int p1 = content.indexOf('if (_youtubeUrls.isNotEmpty) ...[', headerEnd);
        int p2 = content.indexOf('// ===== YOUTUBE VIDEO', headerEnd);
        int p3 = content.indexOf('child: CommonYoutubePlayer(', headerEnd);
        
        if (p1 != -1) {
           videoMatchIndex = p1;
           // look backwards for the start of its indentation/container
           int newlineBefore = content.lastIndexOf('\n', videoMatchIndex);
           if (content.substring(newlineBefore, videoMatchIndex).contains('//')) {
             newlineBefore = content.lastIndexOf('\n', newlineBefore - 1);
           }
           videoMatchIndex = newlineBefore;
        } else if (p2 != -1) {
           videoMatchIndex = content.lastIndexOf('\n', p2);
        } else if (p3 != -1) {
           // This means CommonYoutubePlayer is directly there.
           int idx = content.lastIndexOf('Container(', p3);
           if (idx > headerEnd) {
             videoMatchIndex = content.lastIndexOf('\n', idx);
           }
        }

        if (videoMatchIndex != -1 && videoMatchIndex > headerEnd) {
           String beforeVideo = content.substring(headerEnd, videoMatchIndex);
           
           String topContent = replacementHeader + beforeVideo + '''
                                      ],
                                    ),
                                  ),''';
           
           String afterVideo = content.substring(videoMatchIndex);
           
           // Replace Footer to add necessary brackets
           final footerRegex = RegExp(r'\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*Footer\(');
           if (footerRegex.hasMatch(afterVideo)) {
              afterVideo = afterVideo.replaceFirst(footerRegex, 
              '''],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Footer(''');
              
              content = content.substring(0, match.start) + topContent + afterVideo;
              changed = true;
           }
        }
      }

      if (changed) {
        entity.writeAsStringSync(content);
        print('Modified: \${entity.path}');
        filesModified++;
      }
    }
  }

  print('\nTotal files modified: \$filesModified');
}
