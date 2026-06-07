import os
import re

file_path = r"d:\Flutter Projects\Game\lib\features\home\widgets\battle_pass_mini_widget.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix Colors.black34 to Colors.black38
content = content.replace('Colors.black34', 'Colors.black38')

# Fix withOpacity
content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed!")
