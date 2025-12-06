import requests
import re

def extract_text_nodes(node, results):
    if node.get("type") == "TEXT" and "characters" in node:
        txt = node["characters"].strip()
        if txt and txt not in results:
            results.append(txt)
    for child in node.get("children", []):
        extract_text_nodes(child, results)

def make_key(text):
    clean = re.sub(r'[^A-Za-z0-9 ]+', '', text)
    parts = clean.split()
    if not parts:
        return "unknown"
    return parts[0].lower() + ''.join([p.capitalize() for p in parts[1:])

def main():
    print("=== Figma Strings Extractor ===")
    file_id = input("Enter Figma File ID: ").strip()
    token = input("Enter Personal Access Token: ").strip()

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
    with open("strings.dart", "w") as f:
        f.write("class Strings {\n")
        for txt in texts:
            key = make_key(txt)
            f.write(f'  static const String {key} = "{txt}";\n')
        f.write("}\n")

    print("✔ strings.dart generated successfully!")

if __name__ == "__main__":
    main()
