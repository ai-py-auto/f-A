#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  echo "Usage: curl -sSL <script-url> | bash -s <LanguageName>"
  echo "Example: curl -sSL <script-url> | bash -s Greek"
  exit 1
fi

# Normalize input
lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 Adding Language: $langName"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BASE_DIR="lib/core/languages"
STRINGS_FILE="$BASE_DIR/strings.dart"

# Verify we're in a Flutter project
if [ ! -d "lib" ]; then
  echo "❌ Error: Not in a Flutter project directory!"
  echo "Please run this script from your Flutter project root."
  exit 1
fi

# Create languages directory if not exists
mkdir -p "$BASE_DIR"

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
  
  if [ -z "$strings_list" ]; then
    echo "❌ Error: No string constants found in Strings class"
    exit 1
  fi
  
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
  
  echo "✅ English file created"
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

total_strings=$(wc -l < "$temp_file")
echo "📊 Found $total_strings strings to translate"

# Create new language Dart file
langFile="$BASE_DIR/${lowerName}.dart"

echo "🤖 Translating to $langName using Claude AI..."
echo "⏳ Please wait..."
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
  escaped_value=$(echo "$value" | sed 's/"/\\"/g')
  strings_json="${strings_json}\"$key\":\"$escaped_value\""
done < "$temp_file"
strings_json="${strings_json}}"

rm "$temp_file"

# Prepare translation prompt
read -r -d '' translation_prompt <<EOF
Translate the following English strings to $langName language. Return ONLY a valid JSON object.

Rules:
1. Return ONLY the JSON object, no markdown, no code blocks, no explanations
2. Keep the keys exactly as they are
3. Translate only the values to $langName
4. Maintain proper JSON formatting
5. Preserve any special characters or formatting in the values

English strings:
$strings_json

Return format: {"key": "translated_value", ...}
EOF

# Call Claude API for translation
translations=$(curl -s "https://api.anthropic.com/v1/messages" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-20250514\",
    \"max_tokens\": 4000,
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": $(echo "$translation_prompt" | jq -Rs .)
      }
    ]
  }")

# Check if API call was successful
if [ -z "$translations" ]; then
  echo "❌ Error: Failed to connect to translation API"
  exit 1
fi

# Extract translated text from response
translated_json=$(echo "$translations" | jq -r '.content[0].text' 2>/dev/null)

if [ -z "$translated_json" ] || [ "$translated_json" = "null" ]; then
  echo "❌ Error: Translation failed"
  echo "API Response: $translations"
  exit 1
fi

# Clean JSON - remove markdown code blocks if present
translated_json=$(echo "$translated_json" | sed 's/^```json//g' | sed 's/^```//g' | sed 's/```$//g' | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g')

echo "✅ Translation completed"
echo ""

# Create the Dart file with translations
cat > "$langFile" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

# Parse JSON and create Dart map entries
if command -v jq &> /dev/null; then
  # Use jq if available
  echo "$translated_json" | jq -r 'to_entries | .[] | "\(.key)|\(.value)"' 2>/dev/null | while IFS='|' read -r key value; do
    escaped_value=$(echo "$value" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped_value'," >> "$langFile"
  done
else
  # Fallback without jq
  echo "$translated_json" | grep -oP '"[^"]+"\s*:\s*"[^"]+"' | while IFS= read -r line; do
    key=$(echo "$line" | sed 's/^"\([^"]*\)".*/\1/')
    value=$(echo "$line" | sed 's/^"[^"]*"[[:space:]]*:[[:space:]]*"\(.*\)"$/\1/')
    escaped_value=$(echo "$value" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped_value'," >> "$langFile"
  done
fi

cat >> "$langFile" <<EOF
};
EOF

# Verify file was created successfully
if [ ! -s "$langFile" ] || [ $(wc -l < "$langFile") -le 3 ]; then
  echo "❌ Error: Failed to create language file"
  exit 1
fi

echo "✅ Created $langFile"

# Show preview
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 8 "$langFile"
echo "  ..."
tail -n 2 "$langFile"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "✅ Language Added Successfully: $langName"
echo "📁 Location: $langFile"
echo "📊 Total Strings: $(grep -c "Strings\." "$langFile")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Next Steps:"
echo "1. Import: import 'languages/${lowerName}.dart';"
echo "2. Add to map: '${lowerName}': ${lowerName}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
