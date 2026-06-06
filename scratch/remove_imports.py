import os

to_remove = {
    r"d:\Flutter Projects\Game\lib\features\family\screens\family_screen.dart": [12],
    r"d:\Flutter Projects\Game\lib\features\home\screens\home_screen.dart": [17],
    r"d:\Flutter Projects\Game\lib\features\social\screens\private_chat_screen.dart": [12],
    r"d:\Flutter Projects\Game\lib\providers\family_provider.dart": [11],
    r"d:\Flutter Projects\Game\lib\providers\notification_provider.dart": [6],
    r"d:\Flutter Projects\Game\lib\providers\party_provider.dart": [2],
    r"d:\Flutter Projects\Game\lib\providers\social_provider.dart": [3],
    r"d:\Flutter Projects\Game\lib\services\matchmaking_service.dart": [2, 3, 4, 5],
}

for file_path, lines_to_remove in to_remove.items():
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.read().split('\n')
    
    # Lines are 1-indexed in the dictionary
    for i in sorted(lines_to_remove, reverse=True):
        if 0 <= i - 1 < len(lines):
            del lines[i - 1]
            
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

print("Unused imports removed!")
