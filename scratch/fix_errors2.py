import os
import re

def fix_file(path, replacements):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    # Also fix withOpacity
    content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

base_dir = r"d:\Flutter Projects\Game"

# 1. avatar_inventory_screen.dart
path1 = os.path.join(base_dir, r"lib\features\profile\screens\avatar_inventory_screen.dart")
fix_file(path1, [("user.ownedAvatars.contains(avatar.id)", "user.inventory.premiumAvatars.contains(avatar.id)")])

# 2. store_screen.dart
path2 = os.path.join(base_dir, r"lib\features\store\screens\store_screen.dart")
fix_file(path2, [("AppGradients.glassGradient", "AppGradients.cardGradient")])

# 3. avatar_showcase_widget.dart
path3 = os.path.join(base_dir, r"lib\features\home\widgets\avatar_showcase_widget.dart")
fix_file(path3, [])

# 4. store_provider.dart
path4 = os.path.join(base_dir, r"lib\providers\store_provider.dart")
with open(path4, 'r', encoding='utf-8') as f:
    content4 = f.read()

if "import '../models/user_model.dart';" not in content4:
    content4 = content4.replace("import '../models/store_item_model.dart';", "import '../models/store_item_model.dart';\nimport '../models/user_model.dart';")
    with open(path4, 'w', encoding='utf-8') as f:
        f.write(content4)

print("All fixes applied!")
