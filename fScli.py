#!/usr/bin/env python3
import requests
import re
import sys




def extract_text_nodes(node, results):
    if node.get("type") == "TEXT" and "characters" in node:
        txt = node["characters"].strip()
        if txt and txt not in results:
            results.append(txt)
    for child in node.get("children", []):
        extract_text_nodes(child, results)

def make_key(text):
    clean = re.sub(r'[^A-Za-z ]+', '', text)
    parts = clean.split()
    if not parts:
        return None
    return parts[0].lower() + ''.join([p.capitalize() for p in parts[1:]])

def should_ignore(text):
    # Ignore fully numeric
    if text.isnumeric():
        return True
    # Ignore time formats like "04:00 PM"
    if re.match(r'^\d{1,2}:\d{2}\s?(AM|PM)$', text):
        return True
    # Ignore long text > 5 lines
    if text.count('\n') >= 5:
        return True
    return False

def normalize_text(text):
    # Remove line breaks, make text 1 line
    return ' '.join(text.splitlines()).strip()

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
    extract_text_nodes(data["document"], texts)

    print(f"Found {len(texts)} text items.")
    key_counts = {}
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            txt = normalize_text(txt)
            if should_ignore(txt):
                continue
            key = make_key(txt)
            if not key:
                continue

            # Handle duplicate keys
            if key in key_counts:
                key_counts[key] += 1
                key = f"{key}_{key_counts[key]}"
            else:
                key_counts[key] = 0

            f.write(f'  static const String {key} = "{txt}";\n')
        f.write("}\n")

    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main()
