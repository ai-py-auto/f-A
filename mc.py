#!/usr/bin/env python3



















import requests
import re
import sys

def extract_text_from_frames(node, results):
    """Extract text only from FRAME type nodes (actual screens), ignore layer names"""
    node_type = node.get("type")
    
    # If this is a FRAME, extract text from its children
    if node_type == "FRAME":
        _extract_text_from_children(node, results)
        return  # Don't go deeper into nested frames
    
    # Continue searching for frames
    for child in node.get("children", []):
        extract_text_from_frames(child, results)

def _extract_text_from_children(node, results):
    """Extract only TEXT nodes from within a frame"""
    if node.get("type") == "TEXT" and "characters" in node:
        txt = node["characters"].strip()
        if txt and txt not in results:
            results.append(txt)
    
    for child in node.get("children", []):
        _extract_text_from_children(child, results)

def make_key(text):
    # Remove numbers and special chars except letters (keep key safe)
    clean = re.sub(r'[^A-Za-z ]+', '', text)
    parts = clean.split()
    if not parts:
        return None
    
    # Long text: use first 2-3 words for key
    if len(text.split()) > 5:
        key_parts = parts[:3]  # First 3 words
    else:
        key_parts = parts[:2] if len(parts) >= 2 else parts  # First 2 words
    
    return key_parts[0].lower() + ''.join([p.capitalize() for p in key_parts[1:]])

def should_ignore(text):
    # Fully numeric text ignore
    if text.isnumeric():
        return True
    # Time formats like "04:00 PM" ignore
    if re.match(r'^\d{1,2}:\d{2}\s?(AM|PM)

def normalize_text(text):
    # Remove line breaks, make single line
    return ' '.join(text.splitlines()).strip()

def escape_value(text):
    # Escape dollar sign, double quotes and backslashes in value
    text = text.replace('\\', '\\\\')  # Escape backslash first
    text = text.replace('"', '\\"')    # Escape double quotes
    text = text.replace('$', r'\$')    # Escape dollar sign for Dart
    return text

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 figma_to_strings_cli.py <FILE_ID> <TOKEN>")
        return
    
    file_id = sys.argv[1]
    token = sys.argv[2]
    url = f"https://api.figma.com/v1/files/{file_id}"
    headers = {"X-Figma-Token": token}
    
    print("Fetching Figma file...")
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print("Error fetching file:", e)
        return
    
    data = response.json()
    texts = []
    
    print("Extracting text from frames only (ignoring layer names)...")
    extract_text_from_frames(data["document"], texts)
    
    print(f"Found {len(texts)} text items from design screens.")
    
    key_counts = {}
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            txt = normalize_text(txt)
            if should_ignore(txt):
                continue
            
            value = escape_value(txt)  # safe for Dart
            key = make_key(txt)
            if not key:
                continue
            
            # Handle duplicate keys
            if key in key_counts:
                key_counts[key] += 1
                key = f"{key}_{key_counts[key]}"
            else:
                key_counts[key] = 0
            
            f.write(f'  static const String {key} = "{value}";\n')
        f.write("}\n")
    
    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main(), text):
        return True
    # Single character ignore (S, D, F, etc.)
    if len(text.strip()) == 1:
        return True
    # Color values ignore: rgb(), rgba(), hex colors, color names with numbers
    if re.match(r'^(rgb|rgba)\s*\(', text.lower()):
        return True
    if re.match(r'^#[0-9A-Fa-f]{3,8}

def normalize_text(text):
    # Remove line breaks, make single line
    return ' '.join(text.splitlines()).strip()

def escape_value(text):
    # Escape dollar sign, double quotes and backslashes in value
    text = text.replace('\\', '\\\\')  # Escape backslash first
    text = text.replace('"', '\\"')    # Escape double quotes
    text = text.replace('$', r'\$')    # Escape dollar sign for Dart
    return text

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 figma_to_strings_cli.py <FILE_ID> <TOKEN>")
        return
    
    file_id = sys.argv[1]
    token = sys.argv[2]
    url = f"https://api.figma.com/v1/files/{file_id}"
    headers = {"X-Figma-Token": token}
    
    print("Fetching Figma file...")
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print("Error fetching file:", e)
        return
    
    data = response.json()
    texts = []
    
    print("Extracting text from frames only (ignoring layer names)...")
    extract_text_from_frames(data["document"], texts)
    
    print(f"Found {len(texts)} text items from design screens.")
    
    key_counts = {}
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            txt = normalize_text(txt)
            if should_ignore(txt):
                continue
            
            value = escape_value(txt)  # safe for Dart
            key = make_key(txt)
            if not key:
                continue
            
            # Handle duplicate keys
            if key in key_counts:
                key_counts[key] += 1
                key = f"{key}_{key_counts[key]}"
            else:
                key_counts[key] = 0
            
            f.write(f'  static const String {key} = "{value}";\n')
        f.write("}\n")
    
    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main(), text):
        return True
    if re.match(r'^(white|black|red|blue|green|yellow|gray|grey|primary|secondary)-?\d+

def normalize_text(text):
    # Remove line breaks, make single line
    return ' '.join(text.splitlines()).strip()

def escape_value(text):
    # Escape dollar sign, double quotes and backslashes in value
    text = text.replace('\\', '\\\\')  # Escape backslash first
    text = text.replace('"', '\\"')    # Escape double quotes
    text = text.replace('$', r'\$')    # Escape dollar sign for Dart
    return text

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 figma_to_strings_cli.py <FILE_ID> <TOKEN>")
        return
    
    file_id = sys.argv[1]
    token = sys.argv[2]
    url = f"https://api.figma.com/v1/files/{file_id}"
    headers = {"X-Figma-Token": token}
    
    print("Fetching Figma file...")
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print("Error fetching file:", e)
        return
    
    data = response.json()
    texts = []
    
    print("Extracting text from frames only (ignoring layer names)...")
    extract_text_from_frames(data["document"], texts)
    
    print(f"Found {len(texts)} text items from design screens.")
    
    key_counts = {}
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            txt = normalize_text(txt)
            if should_ignore(txt):
                continue
            
            value = escape_value(txt)  # safe for Dart
            key = make_key(txt)
            if not key:
                continue
            
            # Handle duplicate keys
            if key in key_counts:
                key_counts[key] += 1
                key = f"{key}_{key_counts[key]}"
            else:
                key_counts[key] = 0
            
            f.write(f'  static const String {key} = "{value}";\n')
        f.write("}\n")
    
    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main(), text.lower()):
        return True
    return False

def normalize_text(text):
    # Remove line breaks, make single line
    return ' '.join(text.splitlines()).strip()

def escape_value(text):
    # Escape dollar sign, double quotes and backslashes in value
    text = text.replace('\\', '\\\\')  # Escape backslash first
    text = text.replace('"', '\\"')    # Escape double quotes
    text = text.replace('$', r'\$')    # Escape dollar sign for Dart
    return text

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 figma_to_strings_cli.py <FILE_ID> <TOKEN>")
        return
    
    file_id = sys.argv[1]
    token = sys.argv[2]
    url = f"https://api.figma.com/v1/files/{file_id}"
    headers = {"X-Figma-Token": token}
    
    print("Fetching Figma file...")
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print("Error fetching file:", e)
        return
    
    data = response.json()
    texts = []
    
    print("Extracting text from frames only (ignoring layer names)...")
    extract_text_from_frames(data["document"], texts)
    
    print(f"Found {len(texts)} text items from design screens.")
    
    key_counts = {}
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            txt = normalize_text(txt)
            if should_ignore(txt):
                continue
            
            value = escape_value(txt)  # safe for Dart
            key = make_key(txt)
            if not key:
                continue
            
            # Handle duplicate keys
            if key in key_counts:
                key_counts[key] += 1
                key = f"{key}_{key_counts[key]}"
            else:
                key_counts[key] = 0
            
            f.write(f'  static const String {key} = "{value}";\n')
        f.write("}\n")
    
    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main()
