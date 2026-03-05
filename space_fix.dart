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
      // Normalize line endings to LF to avoid matching issues
      content = content.replaceAll('\r\n', '\n');
      
      String originalPattern = '''
              // ===== MAIN CONTENT =====
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: _contentMaxWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [''';

      String replacementPattern = '''
              // ===== MAIN CONTENT =====
              Expanded(
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
                                maxWidth: _contentMaxWidth,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [''';

      // We use `Column` instead of `Expanded` to wrap the top content since `Expanded` inside `IntrinsicHeight` fails! 
      // Wait, inside IntrinsicHeight, children of Column can be Expanded!
      // Actually, if we use MainAxisAlignment.spaceBetween, we don't need Expanded inside the top!
      // The spacer isn't even needed, we just wrap top content in a Column, then bottom video, 
      // and spaceBetween will push Video to the bottom.

      if (content.contains(originalPattern)) {
        
        String videoPat = '''// ===== YOUTUBE VIDEO SECTION''';
        if (content.contains(videoPat)) {
          // split top content
          content = content.replaceFirst(originalPattern, replacementPattern);
          
          content = content.replaceFirst(
            videoPat, 
            '''
                                    ],
                                  ),
                          $videoPat'''
          );
          
          String originalFooterPattern = '''
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ===== FOOTER''';
          String originalFooterPatternFallback = '''
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // FOOTER''';
              
          String footerRepl = '''
                        ],
                      ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== FOOTER''';
          String footerReplFallback = '''
                        ],
                      ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // FOOTER''';
              
          if (content.contains(originalFooterPattern)) {
            content = content.replaceFirst(originalFooterPattern, footerRepl);
            changed = true;
          } else if (content.contains(originalFooterPatternFallback)) {
            content = content.replaceFirst(originalFooterPatternFallback, footerReplFallback);
            changed = true;
          } else {
             print('Warning: could not find footer replacement in \${entity.path}');
          }
        }
      }

      if (changed) {
        // preserve original windows newlines if preferred, but dart doesn't care
        entity.writeAsStringSync(content);
        print('Modified: \${entity.path}');
        filesModified++;
      }
    }
  }

  print('\nTotal files modified: \$filesModified');
}
