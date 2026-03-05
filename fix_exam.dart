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

      // We look for patterns where SingleChildScrollView is the root of the scrollable area
      final regex1 = RegExp(
          r':\s*SingleChildScrollView\(\s*child:\s*Center\(\s*child:\s*Container\(\s*constraints:\s*BoxConstraints\(maxWidth:\s*maxContentWidth\),\s*child:\s*Column\(\s*mainAxisSize:\s*MainAxisSize\.min,\s*children:\s*\[',
          multiLine: true);
          
      final regex2 = RegExp(
          r'Expanded\(\s*child:\s*SingleChildScrollView\(\s*(?:physics:\s*const[^,]*,)?\s*child:\s*Center\(\s*child:\s*Container\(\s*constraints:[^\)]+\),\s*child:\s*Column\(\s*mainAxisSize:\s*MainAxisSize.(min|max),\s*children:\s*\[',
          multiLine: true);

      if (regex1.hasMatch(content)) {
        final match = regex1.firstMatch(content)!;
        String originalHeader = match.group(0)!;
        String replacementHeader = originalHeader.replaceFirst(
            ': SingleChildScrollView(',
            ''': LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: IntrinsicHeight(
                                      child: ''');
                                      
        replacementHeader = replacementHeader.replaceFirst(
          'mainAxisSize: MainAxisSize.min,',
          'mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,'
        );
        
        replacementHeader = replacementHeader.replaceFirst(
          'children: [',
          'children: [\n                                              Column(\n                                                mainAxisSize: MainAxisSize.min,\n                                                children: ['
        );

        String videoPattern = '// ===== YOUTUBE VIDEO';
        int headerEnd = match.end;
        int videoMatchIndex = content.indexOf(videoPattern, headerEnd);
        
        if (videoMatchIndex != -1) {
           // We need to close the internal column before the video
           // Search backwards for the start of the line
           int commentStart = content.lastIndexOf('\n', videoMatchIndex);
           
           String topContent = replacementHeader + content.substring(headerEnd, commentStart) + '''
                                              ],
                                            ),''';
           
           String afterVideo = content.substring(commentStart);
           
           // We need to close the LayoutBuilder properly.
           // Usually the Expanded has its closing bracket, then ], then SafeArea or something.
           final footerRegex = RegExp(r'\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\]\s*,\s*\)\s*,');
           if (footerRegex.hasMatch(afterVideo)) {
              afterVideo = afterVideo.replaceFirst(RegExp(r'\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\]\s*,\s*\)\s*,'), 
              '''],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),''');
              
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
