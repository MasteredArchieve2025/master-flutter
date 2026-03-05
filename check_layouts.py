import os

files = [
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
]

for f in files:
    try:
        with open(f, 'r') as file:
            content = file.read()
            if 'CustomScrollView' in content:
                print(f"{f} uses CustomScrollView")
            elif 'SingleChildScrollView' in content:
                print(f"{f} uses SingleChildScrollView")
            else:
                print(f"{f} unknown structure")
    except Exception as e:
        print(f"Error {f}: {e}")
