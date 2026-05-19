import os
import re

target_dir = "lib"

replacements = [
    # Specific colors first
    (r'AppColors\.background', 'Theme.of(context).scaffoldBackgroundColor'),
    (r'AppColors\.primary', 'Theme.of(context).colorScheme.primary'),
    (r'AppColors\.foreground', 'Theme.of(context).colorScheme.onSurface'),
    (r'AppColors\.border', 'Theme.of(context).colorScheme.outline'),
    (r'AppColors\.mutedForeground', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    (r'AppColors\.destructive', 'Theme.of(context).colorScheme.error'),
    (r'AppColors\.secondary', 'Theme.of(context).colorScheme.secondary'),
    
    (r'Colors\.white', 'Theme.of(context).cardColor'),
    
    # Specific blacks first
    (r'Colors\.black87', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)'),
    (r'Colors\.black54', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)'),
    (r'Colors\.black45', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)'),
    (r'Colors\.black38', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)'),
    (r'Colors\.black26', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26)'),
    (r'Colors\.black12', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)'),
    (r'Colors\.black', 'Theme.of(context).colorScheme.onSurface'),
    
    # Greys
    (r'Colors\.grey\.shade50', 'Theme.of(context).colorScheme.surfaceContainerLowest'),
    (r'Colors\.grey\.shade100', 'Theme.of(context).colorScheme.surfaceContainerLow'),
    (r'Colors\.grey\.shade200', 'Theme.of(context).colorScheme.outlineVariant'),
    (r'Colors\.grey\.shade300', 'Theme.of(context).colorScheme.outline'),
    (r'Colors\.grey\.shade400', 'Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)'),
    (r'Colors\.grey', 'Theme.of(context).colorScheme.onSurfaceVariant'),
]

for root, dirs, files in os.walk(target_dir):
    for file in files:
        if file.endswith(".dart") and file not in ["app_colors.dart", "main.dart"]:
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            
            # Remove const before common widgets that might now have Theme.of
            content = re.sub(r'const\s+(Padding|Container|SizedBox|Column|Row|Icon|Text|Center|Align|Expanded|Flexible|Card|BoxDecoration|ListTile|BorderSide|Divider|EdgeInsets|BorderRadius|OutlineInputBorder|InputDecoration|TextStyle|IconButton|OutlinedButton|ElevatedButton|TextButton|Widget)', r'\1', content)
            
            # Apply replacements
            for old, new in replacements:
                content = re.sub(old, new, content)
                
            # Add ThemeToggle to AppBar action
            # Make sure it adds cleanly without breaking existing actions
            if "AppBar(" in content and "ThemeToggle" not in content:
                # Add to existing actions, or add actions if none exist
                if "actions:" in content:
                    content = re.sub(r"actions:\s*\[", "actions: [const ThemeToggle(), ", content)
                else:
                    content = re.sub(r"AppBar\(\s*title:\s*(const\s+)?Text\('([^']+)'\)", r"AppBar(title: const Text('\2'), actions: [const ThemeToggle()],", content)
                    content = re.sub(r"AppBar\(\s*title:\s*(const\s+)?Text\(([^)]+)\)", r"AppBar(title: Text(\2), actions: [const ThemeToggle()],", content)
            
            # Import main.dart if ThemeToggle was added
            if "ThemeToggle" in content and "package:gosir/main.dart" not in content:
                content = "import 'package:gosir/main.dart';\n" + content
            
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
