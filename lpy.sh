#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  echo "Usage: ./script.sh <LanguageName>"
  exit 1
fi

lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 Adding Language: $langName"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BASE_DIR="lib/core/languages"
STRINGS_FILE="$BASE_DIR/strings.dart"

if [ ! -d "lib" ]; then
  echo "❌ Error: Not in a Flutter project directory!"
  exit 1
fi

mkdir -p "$BASE_DIR"

if [ ! -f "$STRINGS_FILE" ]; then
  echo "❌ Strings class missing at $STRINGS_FILE"
  exit 1
fi

englishFile="$BASE_DIR/english.dart"

# Create english.dart if missing
if [ ! -f "$englishFile" ]; then
  echo "📝 Creating english.dart..."

  strings_list=$(grep -oP 'static const String \K\w+(?=\s*=)' "$STRINGS_FILE")

  if [ -z "$strings_list" ]; then
    echo "❌ No string constants found!"
    exit 1
  fi

  cat > "$englishFile" <<EOF
import 'strings.dart';

Map<String, String> english = {
EOF

  while IFS= read -r key; do
    value=$(grep "static const String $key" "$STRINGS_FILE" | grep -oP '=\s*"\K[^"]*')
    echo "  Strings.$key: \"$value\"," >> "$englishFile"
  done <<< "$strings_list"

  echo "};" >> "$englishFile"
  echo "✅ english.dart created"
fi

echo "📝 Extracting strings from english.dart..."
temp_file=$(mktemp)

grep -oP 'Strings\.\w+:\s*"[^"]*"' "$englishFile" | while IFS= read -r line; do
  key=$(echo "$line" | grep -oP 'Strings\.\K\w+(?=:)')
  value=$(echo "$line" | grep -oP ':\s*"\K[^"]*')
  echo "$key|$value" >> "$temp_file"
done

total_strings=$(wc -l < "$temp_file")
echo "📊 Found $total_strings strings"

# Language selection
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

# Create new language file
langFile="$BASE_DIR/${lowerName}.dart"
cat > "$langFile" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

echo "🌐 Translating using Google Translate API..."
counter=0
all_success=true

while IFS='|' read -r key value; do
  counter=$((counter + 1))
  echo -ne "\r⏳ Translating... [$counter/$total_strings]"

  # URL encode
  encoded=$(python3 - <<EOF
import urllib.parse
print(urllib.parse.quote("$value"))
EOF
)

  translated=$(curl -sL --max-time 5 \
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${target_lang}&dt=t&q=${encoded}" | \
    grep -oP '\[\[\[".*?"' | head -1 | cut -d'"' -f2)

  if [ -z "$translated" ]; then
    escaped=$(echo "$value" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped', // TODO" >> "$langFile"
    all_success=false
  else
    escaped=$(echo "$translated" | sed "s/'/\\\\'/g")
    echo "  Strings.$key: '$escaped'," >> "$langFile"
  fi

  sleep 0.15
done < "$temp_file"

echo "};" >> "$langFile"
rm "$temp_file"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 Preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -n 10 "$langFile"
echo "  ..."
tail -n 2 "$langFile"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Output: $langFile"
echo "📊 Total Strings: $(grep -c "Strings\." "$langFile")"

if ! $all_success; then
  echo "⚠️ Some lines need manual translation (marked with // TODO)"
fi
