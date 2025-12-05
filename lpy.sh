#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  echo "Usage: ./script.sh <LanguageName>"
  echo "Example: ./script.sh Arabic"
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
echo ""

# Create new language Dart file
langFile="$BASE_DIR/${lowerName}.dart"

# Check if we can use online translation
echo "🔍 Checking translation method..."
echo ""

# Try to use Google Translate via web scraping (no API key needed)
translated_values=()
all_success=true

echo "🌐 Using Google Translate (free service)..."
echo "⏳ Translating strings..."
echo ""

# Get language code for Google Translate
get_lang_code() {
  case "$1" in
    Arabic|arabic) echo "ar" ;;
    Spanish|spanish) echo "es" ;;
    French|french) echo "fr" ;;
    German|german) echo "de" ;;
    Italian|italian) echo "it" ;;
    Portuguese|portuguese) echo "pt" ;;
    Russian|russian) echo "ru" ;;
    Japanese|japanese) echo "ja" ;;
    Korean|korean) echo "ko" ;;
    Chinese|chinese) echo "zh-CN" ;;
    Hindi|hindi) echo "hi" ;;
    Bengali|bengali) echo "bn" ;;
    Greek|greek) echo "el" ;;
    Turkish|turkish) echo "tr" ;;
    Dutch|dutch) echo "nl" ;;
    Swedish|swedish) echo "sv" ;;
    Polish|polish) echo "pl" ;;
    *) echo "auto" ;;
  esac
}

target_lang=$(get_lang_code "$langName")

# Create language file with placeholder
cat > "$langFile" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

counter=0
while IFS='|' read -r key value; do
  counter=$((counter + 1))
  echo -ne "\r⏳ Translating... [$counter/$total_strings]"
  
  # URL encode the text
  encoded_text=$(echo "$value" | jq -sRr @uri 2>/dev/null || python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$value" 2>/dev/null || echo "$value")
  
  # Try translation
  translated=$(curl -sL --max-time 5 \
    -A "Mozilla/5.0" \
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${target_lang}&dt=t&q=${encoded_text}" 2>/dev/null | \
    grep -oP '\[\[\[".*?"' | head -1 | cut -d'"' -f2 2>/dev/null)
  
  if [ -n "$translated" ] && [ "$translated" != "$value" ]; then
    # Escape single quotes
    escaped_value=$(echo "$translated" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped_value'," >> "$langFile"
  else
    # Keep original if translation fails
    escaped_value=$(echo "$value" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped_value', // TODO: Translate" >> "$langFile"
    all_success=false
  fi
  
  # Small delay to avoid rate limiting
  sleep 0.2
done < "$temp_file"

cat >> "$langFile" <<EOF
};
EOF

rm "$temp_file"

echo ""
echo ""

if [ "$all_success" = true ]; then
  echo "✅ All strings translated successfully!"
else
  echo "⚠️  Some strings couldn't be translated automatically"
  echo "📝 Please manually translate strings marked with // TODO"
fi

echo ""
echo "✅ Created $langFile"

# Show preview
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 10 "$langFile"
echo "  ..."
tail -n 2 "$langFile"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "✅ Language Added: $langName"
echo "📁 Location: $langFile"
echo "📊 Total Strings: $(grep -c "Strings\." "$langFile")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Next Steps:"
echo "1. Import: import 'languages/${lowerName}.dart';"
echo "2. Add to map: '${lowerName}': ${lowerName}"

if [ "$all_success" = false ]; then
  echo ""
  echo "⚠️  Manual Review Required:"
  echo "   Open $langFile and translate strings marked with // TODO"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
