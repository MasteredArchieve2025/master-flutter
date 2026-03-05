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
      // Keep LF line endings
      content = content.replaceAll('\r\n', '\n');

      if (!content.contains('CommonYoutubePlayer')) {
        continue;
      }
      
      // Skip if already applied
      if (content.contains('child: LayoutBuilder(') && content.contains('child: IntrinsicHeight(')) {
        continue;
      }

      int sPos = content.indexOf('SingleChildScrollView(\n                              child: Center(');
      if (sPos == -1) {
         sPos = content.indexOf('SingleChildScrollView(\n                                  child: Center(');
      }
      if (sPos == -1) {
         sPos = content.indexOf('SingleChildScrollView(\n                                child: Center(');
      }
      if (sPos == -1) {
         print('Could not find SingleChildScrollView in \${entity.path}');
         continue;
      }
      
      // Find `children: [` after `sPos`
      int childrenPos = content.indexOf('children: [', sPos);
      if (childrenPos == -1) continue;
      
      // Look for the part we want to replace
      String targetToReplace = content.substring(sPos, childrenPos + 11);
      
      String replacementStr = 'LayoutBuilder(\n'
          '                              builder: (context, constraints) {\n'
          '                                return SingleChildScrollView(\n'
          '                                  physics: const BouncingScrollPhysics(),\n'
          '                                  child: ConstrainedBox(\n'
          '                                    constraints: BoxConstraints(\n'
          '                                      minHeight: constraints.maxHeight,\n'
          '                                    ),\n'
          '                                    child: IntrinsicHeight(\n'
          '                                      child: Center(\n'
          '                                        child: Container(\n'
          '                                          constraints: BoxConstraints(maxWidth: isDesktop ? 1400 : double.infinity),\n'
          '                                          child: Column(\n'
          '                                            mainAxisSize: MainAxisSize.max,\n'
          '                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,\n'
          '                                            children: [\n'
          '                                              Column(\n'
          '                                                mainAxisSize: MainAxisSize.min,\n'
          '                                                children: [';
                                                
      content = content.replaceFirst(targetToReplace, replacementStr);
      
      // Split the Youtube section
      String videoPattern = 'if (youtubeUrls.isNotEmpty)';
      if (!content.contains(videoPattern)) {
        videoPattern = 'if (_youtubeUrls.isNotEmpty)';
      }
      
      int vPos = content.lastIndexOf('\n', content.indexOf(videoPattern, childrenPos));
      if (vPos != -1) {
        String insertBeforeVid = '                                                ],\n'
                                 '                                              ),\n';
        content = content.substring(0, vPos) + '\n' + insertBeforeVid + content.substring(vPos);
      }
      
      // Close LayoutBuilder at the end of the scrollview.
      // Usually right before `// Full screen loader` or `bottomNavigationBar`
      int loaderPos = content.indexOf('// Full screen loader');
      if (loaderPos == -1) {
        loaderPos = content.indexOf('bottomNavigationBar');
      }
      if (loaderPos != -1) {
         // Find the closing brackets before loaderPos
         int bracketStart = content.lastIndexOf('],', loaderPos);
         if (bracketStart != -1) {
             // Go back a few lines until `],`
             int closingSeqStart = content.lastIndexOf('\n', content.lastIndexOf('\n', bracketStart));
             String closingReplacement = '''
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
              ],
            ),
          ),''';
          
          // Replace exactly the closing brackets sequence
          // We know it is roughly:
          //                                     ],
          //                                   ),
          //                                 ),
          //                               ),
          //                             ),
          //                 ),
          //               ],
          //             ),
          //           ),
          
          final regexBrackets = RegExp(r'\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\]\s*,\s*\)\s*,\s*\)\s*,', multiLine: true);
          final match = regexBrackets.firstMatch(content);
          if (match != null) {
              content = content.replaceFirst(match.group(0)!, '''],
                                          ),
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
          } else {
             // Let's try matching with one less `),` 
             final regexBrackets2 = RegExp(r'\]\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\)\s*,\s*\]\s*,\s*\)\s*,\s*\)\s*,', multiLine: true);
             final match2 = regexBrackets2.firstMatch(content);
             if (match2 != null) {
                content = content.replaceFirst(match2.group(0)!, '''],
                                          ),
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
             }
          }
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
