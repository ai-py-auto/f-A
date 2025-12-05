#!/usr/bin/env python3

import re
import sys
from pathlib import Path
from collections import defaultdict

def parse_strings_dart(file_path):
    """Parse strings.dart and extract static const String declarations"""
    strings_map = []
    value_to_keys = defaultdict(list)
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return None, None
    
    # Pattern to match: static const String varName = "value";
    pattern = r'static\s+const\s+String\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*"([^"]*(?:\\.[^"]*)*)"\s*;'
    
    matches = re.finditer(pattern, content, re.MULTILINE)
    
    for match in matches:
        var_name = match.group(1)
        var_value = match.group(2)
        
        # Track duplicate values
        value_to_keys[var_value].append(var_name)
        
        # Escape single quotes for Dart string
        var_value = var_value.replace("'", "\\'")
        
        strings_map.append((var_name, var_value))
    
    return strings_map, value_to_keys

def find_duplicates(value_to_keys):
    """Find duplicate string values"""
    duplicates = {}
    for value, keys in value_to_keys.items():
        if len(keys) > 1:
            duplicates[value] = keys
    return duplicates

def generate_language_dart(strings_map, output_path, language_name):
    """Generate language.dart file with Map<String, String> format"""
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("import 'strings.dart';\n\n")
        f.write(f"Map<String, String> {language_name.lower()} = {{\n")
        
        for var_name, var_value in strings_map:
            f.write(f"  Strings.{var_name}: '{var_value}',\n")
        
        f.write("};\n")

def get_language_name():
    """Ask user for language name"""
    print("\n🌍 Available Languages Examples:")
    print("   • English")
    print("   • Arabic (العربية)")
    print("   • Bengali (বাংলা)")
    print("   • Spanish (Español)")
    print("   • French (Français)")
    print("   • German (Deutsch)")
    print()
    
    try:
        language = input("📥 Enter language name: ").strip()
    except (EOFError, KeyboardInterrupt):
        print("\n\n❌ Input cancelled!")
        sys.exit(1)
    
    if not language:
        print("❌ Language name cannot be empty!")
        return get_language_name()
    
    return language

def main():
    print("🛠️ Creating Multi Language Method...")
    print("=" * 54)
    
    # Define paths
    strings_file = Path("lib/core/languages/strings.dart")
    output_dir = Path("lib/core/languages")
    
    # Check if strings.dart exists
    if not strings_file.exists():
        print(f"\n❌ Error: {strings_file} not found!")
        print("💡 Make sure you run this from your Flutter project root")
        print()
        return 1
    
    # Get language name from user
    language_name = get_language_name()
    
    # Create output file name
    output_file = output_dir / f"{language_name.lower()}.dart"
    
    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Check if file exists
    if output_file.exists():
        print(f"\n⚠️  File {output_file} already exists!")
        try:
            overwrite = input("Do you want to overwrite it? (y/n): ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print("\n\n❌ Aborted!")
            return 0
        
        if overwrite != 'y':
            print("❌ Aborted!")
            return 0
    
    # Parse and generate
    try:
        print(f"\n📖 Reading {strings_file}...")
        strings_map, value_to_keys = parse_strings_dart(strings_file)
        
        if strings_map is None:
            print(f"❌ Could not read {strings_file}")
            return 1
        
        # Check for duplicates
        duplicates = find_duplicates(value_to_keys)
        
        if duplicates:
            print("\n⚠️  Duplicate values detected:")
            for value, keys in list(duplicates.items())[:5]:  # Show first 5
                print(f"   • '{value}' → {', '.join(keys)}")
            
            if len(duplicates) > 5:
                print(f"   ... and {len(duplicates) - 5} more")
            print()
        
        print(f"✍️  Generating {output_file}...")
        generate_language_dart(strings_map, output_file, language_name)
        
        print()
        print("=" * 54)
        print(f"✅ Successfully created {output_file}")
        print(f"📝 Total entries: {len(strings_map)}")
        print(f"🎉 Language '{language_name}' file is ready!")
        print()
        
        if duplicates:
            print(f"⚠️  Warning: Found {len(duplicates)} duplicate value(s)")
            print("💡 These may cause 'duplicate key' errors in Dart")
            print("💡 Fix: Remove duplicate keys from strings.dart")
            print()
        
        print("📌 Next Steps:")
        print(f"   1. Translate values in: {output_file}")
        print(f"   2. Import in your app:")
        print(f"      import 'package:yourapp/core/languages/{language_name.lower()}.dart';")
        print()
        print("🎯 Usage Example:")
        print(f"   String text = {language_name.lower()}[Strings.login] ?? 'Login';")
        print()
        
        return 0
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
