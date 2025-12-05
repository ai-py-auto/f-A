#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  echo "Usage: ./script.sh <LanguageName>"
  echo "Example: ./script.sh Greek"
  exit 1
fi

# Normalize input
lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

echo "---------------------------------------------"
echo "🌍 Adding Language: $langName"
echo "---------------------------------------------"

BASE_DIR="lib/core/languages"
mkdir -p "$BASE_DIR"

STRINGS_FILE="lib/core/languages/strings.dart"

# Check if Strings class exists
if [ ! -f "$STRINGS_FILE" ]; then
  echo "❌ Error: Strings class not found at $STRINGS_FILE"
  echo "Please create the Strings class first!"
  exit 1
fi

# English always exists
englishFile="$BASE_DIR/english.dart"
if [ ! -f "$englishFile" ]; then
  cat > "$englishFile" <<'EOF'
import '../constants/strings.dart';

Map<String, String> english = {
  Strings.continues: "Continue",
  Strings.login: "Login",
  Strings.greek: "Greek",
  Strings.language: "Language",
  Strings.welcomeBackYouBeenMissed: "Welcome Back, You've been missed.",
};
EOF
  echo "✔ English file created"
fi

# Extract all string values from english.dart for translation
echo "📝 Extracting strings from english.dart..."
strings_to_translate=$(grep -oP "Strings\.\w+:\s*[\"'].*?[\"']" "$englishFile" | sed "s/Strings\.//g" | sed "s/:\s*/|/g" | sed "s/[\"']//g")

if [ -z "$strings_to_translate" ]; then
  echo "❌ Error: Could not extract strings from english.dart"
  exit 1
fi

# Create new language Dart file
langFile="$BASE_DIR/${lowerName}.dart"

echo "🤖 Translating strings to $langName using Claude AI..."
echo ""

# Prepare translation prompt
translation_prompt="Translate the following English strings to $langName language. Return ONLY a JSON object with the format {\"key\": \"translated_value\"}. Do not include any markdown, code blocks, or explanations.

English strings to translate:
$strings_to_translate

Return format example:
{\"continues\": \"Translated text\", \"login\": \"Translated text\"}"

# Call Claude API for translation
translations=$(curl -s "https://api.anthropic.com/v1/messages" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-20250514\",
    \"max_tokens\": 2000,
    \"messages\": [
      {\"role\": \"user\", \"content\": \"$translation_prompt\"}
    ]
  }")

# Extract translated text from response
translated_json=$(echo "$translations" | grep -oP '"text":\s*"\K[^"]*' | head -1 | sed 's/\\n/\n/g' | sed 's/\\"/"/g')

if [ -z "$translated_json" ]; then
  echo "❌ Error: Translation failed"
  echo "Response: $translations"
  exit 1
fi

# Clean JSON if it has markdown code blocks
translated_json=$(echo "$translated_json" | sed 's/^```json//g' | sed 's/^```//g' | sed 's/```$//g' | xargs)

echo "✔ Translation completed"
echo ""

# Create the Dart file with translations
cat > "$langFile" <<EOF
import '../constants/strings.dart';

Map<String, String> ${lowerName} = {
EOF

# Parse JSON and create Dart map entries
echo "$translated_json" | grep -oP '"[^"]+"\s*:\s*"[^"]+"' | while IFS= read -r line; do
  key=$(echo "$line" | grep -oP '^"[^"]+' | sed 's/"//g')
  value=$(echo "$line" | grep -oP ':\s*"\K[^"]+')
  echo "  Strings.$key: \"$value\"," >> "$langFile"
done

cat >> "$langFile" <<EOF
};
EOF

echo "✔ Created $langFile"

echo "---------------------------------------------"
echo "✅ Language Added Successfully: $langName"
echo "📁 Location: $langFile"
echo "---------------------------------------------"
echo ""
echo "💡 Next steps:"
echo "1. Import in your localization file: import 'languages/${lowerName}.dart';"
echo "2. Add to language map: '${lowerName}': ${lowerName}"
echo "---------------------------------------------"
