import os

files_to_fix = [
    r"d:\Flutter Projects\Game\lib\features\family\screens\family_chat_screen.dart",
    r"d:\Flutter Projects\Game\lib\features\family\screens\family_screen.dart",
    r"d:\Flutter Projects\Game\lib\features\home\screens\home_screen.dart",
    r"d:\Flutter Projects\Game\lib\features\social\screens\private_chat_screen.dart",
    r"d:\Flutter Projects\Game\lib\providers\family_provider.dart",
    r"d:\Flutter Projects\Game\lib\providers\notification_provider.dart",
    r"d:\Flutter Projects\Game\lib\providers\party_provider.dart",
    r"d:\Flutter Projects\Game\lib\providers\social_provider.dart",
]

for file_path in files_to_fix:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace the variable name
    new_content = content.replace('wsServiceProvider', 'webSocketServiceProvider')

    # Add the import if not present
    import_stmt = "import 'package:mafia_wars/providers/matchmaking_provider.dart';"
    if 'webSocketServiceProvider' in new_content and 'matchmaking_provider.dart' not in new_content:
        # Find the last import statement and add it after
        lines = new_content.split('\n')
        last_import_idx = -1
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import_idx = i
        
        if last_import_idx != -1:
            lines.insert(last_import_idx + 1, import_stmt)
            new_content = '\n'.join(lines)
        else:
            new_content = import_stmt + '\n' + new_content

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

# Fix matchmaking_service.dart
mm_path = r"d:\Flutter Projects\Game\lib\services\matchmaking_service.dart"
with open(mm_path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'websocket_service.dart' not in content:
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import_idx = i
    
    import_stmt = "import 'websocket_service.dart';"
    if last_import_idx != -1:
        lines.insert(last_import_idx + 1, import_stmt)
        content = '\n'.join(lines)
    else:
        content = import_stmt + '\n' + content

with open(mm_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed!")
