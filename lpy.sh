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

# Define Strings class location
STRINGS_FILE="$BASE_DIR/strings.dart"

# Check if Strings class exists
if [ ! -f "$STRINGS_FILE" ]; then
  echo "❌ Error: Strings class not found at $STRINGS_FILE"
  echo "Please create the Strings class first!"
  exit 1
fi

# English always exists
englishFile="$BASE_DIR/english.dart"
if [ ! -f "$englishFile" ]; then
  echo "📝 Creating english.dart from Strings class..."
  
  # Extract all const String declarations
  strings_list=$(grep -oP 'static const String \K\w+(?=\s*=)' "$STRINGS_FILE")
  
  cat > "$englishFile" <<EOF
import 'strings.dart';

Map<String, String> english = {
EOF

  # Read each string and get its value
  while IFS= read -r key; do
    value=$(grep "static const String $key" "$STRINGS_FILE" | grep -oP '=\s*"\K[^"]*')
    if [ -n "$value" ]; then
      echo "  Strings.$key: \"$value\"," >> "$englishFile"
    fi
  done <<< "$strings_list"

  echo "};" >> "$englishFile"
  
  echo "✔ English file created"
fi

# Extract all string key-value pairs from english.dart for translation
echo "📝 Extracting strings from english.dart..."

# Create a clean list for translation
temp_file=$(mktemp)
grep -oP 'Strings\.\w+:\s*"[^"]*"' "$englishFile" | while IFS= read -r line; do
  key=$(echo "$line" | grep -oP 'Strings\.\K\w+(?=:)')
  value=$(echo "$line" | grep -oP ':\s*"\K[^"]*')
  echo "$key|$value" >> "$temp_file"
done

if [ ! -s "$temp_file" ]; then
  echo "❌ Error: Could not extract strings from english.dart"
  rm "$temp_file"
  exit 1
fi

# Create new language Dart file
langFile="$BASE_DIR/${lowerName}.dart"

echo "🤖 Translating strings to $langName using Claude AI..."
echo ""

# Prepare strings for translation
strings_json="{"
first=true
while IFS='|' read -r key value; do
  if [ "$first" = true ]; then
    first=false
  else
    strings_json="${strings_json},"
  fi
  # Escape quotes in value
  escaped_value=$(echo "$value" | sed 's/"/\\"/g')
  strings_json="${strings_json}\"$key\":\"$escaped_value\""
done < "$temp_file"
strings_json="${strings_json}}"

rm "$temp_file"

# Prepare translation prompt
translation_prompt="Translate the following English strings to $langName language. Return ONLY a valid JSON object with the format {\"key\": \"translated_value\"}. Do not include any markdown, code blocks, explanations, or any text outside the JSON object.

English strings to translate:
$strings_json

Important: 
1. Return ONLY the JSON object, nothing else
2. Keep the keys exactly as they are
3. Translate only the values
4. Maintain proper JSON formatting"

# Call Claude API for translation
translations=$(curl -s "https://api.anthropic.com/v1/messages" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-20250514\",
    \"max_tokens\": 4000,
    \"messages\": [
      {\"role\": \"user\", \"content\": $(echo "$translation_prompt" | jq -Rs .)}
    ]
  }")

# Extract translated text from response
translated_json=$(echo "$translations" | grep -oP '"text":\s*"\K[^"]*(?=")' | head -1)

if [ -z "$translated_json" ]; then
  echo "❌ Error: Translation failed"
  echo "API Response: $translations"
  exit 1
fi

# Decode escaped characters
translated_json=$(echo "$translated_json" | sed 's/\\n/\n/g' | sed 's/\\"/"/g' | sed 's/\\//g')

# Clean JSON if it has markdown code blocks
translated_json=$(echo "$translated_json" | sed 's/^```json//g' | sed 's/^```//g' | sed 's/```$//g' | sed 's/^[[:space:]]*//g')

echo "✔ Translation completed"
echo ""

# Create the Dart file with translations
cat > "$langFile" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

# Parse JSON and create Dart map entries
echo "$translated_json" | jq -r 'to_entries | .[] | "\(.key)|\(.value)"' 2>/dev/null | while IFS='|' read -r key value; do
  # Escape single quotes in value
  escaped_value=$(echo "$value" | sed "s/'/\\\\'/g")
  echo "  Strings.$key: '$escaped_value'," >> "$langFile"
done

# Fallback if jq fails - use grep and sed
if [ ! -s "$langFile" ] || [ $(wc -l < "$langFile") -le 3 ]; then
  # Clear file and start over
  cat > "$langFile" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

  echo "$translated_json" | grep -oP '"[^"]+"\s*:\s*"[^"]+"' | while IFS= read -r line; do
    key=$(echo "$line" | grep -oP '^"\K[^"]+')
    value=$(echo "$line" | grep -oP ':\s*"\K[^"]+')
    escaped_value=$(echo "$value" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped_value'," >> "$langFile"
  done
fi

cat >> "$langFile" <<EOF
};
EOF

echo "✔ Created $langFile"

# Show preview
echo ""
echo "📄 Preview of generated file:"
echo "---------------------------------------------"
head -n 10 "$langFile"
echo "  ..."
echo "};"
echo "---------------------------------------------"

echo ""
echo "✅ Language Added Successfully: $langName"
echo "📁 Location: $langFile"
echo "---------------------------------------------"
echo ""
echo "💡 Next steps:"
echo "1. Import in your localization file: import 'languages/${lowerName}.dart';"
echo "2. Add to language map: '${lowerName}': ${lowerName}"
echo "---------------------------------------------"
