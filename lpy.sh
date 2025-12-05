#!/usr/bin/env python3

import re
import os
from pathlib import Path

def parse_strings_dart(file_path):
    """Parse strings.dart and extract static const String declarations"""
    strings_map = []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to match: static const String varName = "value";
    # Handles multi-line strings and various formats
    pattern = r'static\s+const\s+String\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*"([^"]*(?:\\.[^"]*)*)"\s*;'
    
    matches = re.finditer(pattern, content, re.MULTILINE)
    
    for match in matches:
        var_name = match.group(1)
        var_value = match.group(2)
        
        # Escape single quotes for Dart string
        var_value = var_value.replace("'", "\\'")
        # Handle escaped characters
        var_value = var_value.replace('\\n', '\\n')
        
        strings_map.append((var_name, var_value))
    
    return strings_map

def generate_english_dart(strings_map, output_path):
    """Generate english.dart file with Map<String, String> format"""
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("import 'strings.dart';\n\n")
        f.write("Map<String, String> english = {\n")
        
        for var_name, var_value in strings_map:
            f.write(f"  Strings.{var_name}: '{var_value}',\n")
        
        f.write("};\n")

def main():
    print("🛠️ Creating Multi Language Method...")
    
    # Define paths
    strings_file = Path("lib/core/languages/strings.dart")
    output_dir = Path("lib/core/languages")
    output_file = output_dir / "english.dart"
    
    # Check if strings.dart exists
    if not strings_file.exists():
        print(f"❌ Error: {strings_file} not found!")
        return 1
    
    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Parse and generate
    try:
        strings_map = parse_strings_dart(strings_file)
        generate_english_dart(strings_map, output_file)
        
        print(f"✅ Successfully created {output_file}")
        print(f"📝 Total entries: {len(strings_map)}")
        return 0
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return 1

if __name__ == "__main__":
    exit(main())
