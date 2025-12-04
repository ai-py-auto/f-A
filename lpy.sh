#!/bin/bash
set -euo pipefail

echo "------------------------------------------------"
echo "   🌍 Flutter Auto Language Map Generator"
echo "------------------------------------------------"
echo ""

# ask language
read -p "🗣️  Enter target language (example: greek, spanish, arabic): " lang
if [ -z "$lang" ]; then
  echo "❌ Language name required!"
  exit 1
fi

# ask language code (ISO)
read -p "🌐 Enter language code (example: el, es, ar): " langCode
if [ -z "$langCode" ]; then
  echo "❌ Language code required!"
  exit 1
fi

mkdir -p lib/core/languages

echo ""
echo "📥 Paste your static strings here (CTRL+D to finish):"
echo "-----------------------------------------------------"

input=$(cat)

# Extract constants
constants=$(echo "$input" | grep "static const" | sed -E 's/static const String ([a-zA-Z0-9_]+) = "(.*)";/\1|\2/g')

if [ -z "$constants" ]; then
  echo "❌ No valid static const strings found!"
  exit 1
fi

# Python translate + generate map
python3 <<EOF
import re
from deep_translator import GoogleTranslator

lang = "$lang"
code = "$langCode"

pairs = """$constants""".strip().split("\n")

english_map = []
lang_map = []

print("🌐 Translating... please wait...\n")

translator = GoogleTranslator(source='auto', target=code)

for row in pairs:
    key, value = row.split("|")

    try:
        translated = translator.translate(value)
    except Exception:
        translated = value

    english_map.append(f'  Strings.{key}: "{value}",')
    lang_map.append(f'  Strings.{key}: "{translated}",')

english_output = "Map<String, String> english = {\n" + "\n".join(english_map) + "\n};"
lang_output = f"Map<String, String> {lang} = {{\n" + "\n".join(lang_map) + "\n};"

with open("lib/core/languages/english.dart", "w") as f:
    f.write(english_output)

with open(f"lib/core/languages/{lang}.dart", "w") as f:
    f.write(lang_output)

print("------------------------------------------------")
print("✅ Files generated inside lib/core/languages/")
print("   • english.dart")
print(f"   • {lang}.dart")
print("------------------------------------------------")
EOF
