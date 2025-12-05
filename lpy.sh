#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  echo "Usage: ./generate_lang.sh <LanguageName>"
  exit 1
fi

# Normalize input
lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 Adding Language: $langName"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BASE_DIR="lib/core/languages"
STRINGS_FILE="$BASE_DIR/strings.dart"
LANG_FILE="$BASE_DIR/${lowerName}.dart"

# Verify project
if [ ! -d "lib" ]; then
  echo "❌ Error: Not in a Flutter project directory!"
  exit 1
fi

mkdir -p "$BASE_DIR"

# Check Strings file
if [ ! -f "$STRINGS_FILE" ]; then
  echo "❌ Error: Strings class not found at $STRINGS_FILE"
  exit 1
fi

# Extract all strings (including multi-line) safely
echo "📝 Extracting strings from Strings class..."
temp_file=$(mktemp)

awk '
/static (const )?String/ {
  key=$3
  val=""
  getline
  if ($0 ~ /'''/) {
    # Multi-line string
    while ($0 !~ /'''/) {
      val = val $0 "\n"
      getline
    }
  } else {
    match($0, /=\s*"(.*)"/, arr)
    val=arr[1]
  }
  print key "|" val
}
' "$STRINGS_FILE" > "$temp_file"

total_strings=$(wc -l < "$temp_file")
echo "📊 Found $total_strings strings"
echo ""

# Create new language file
cat > "$LANG_FILE" <<EOF
import 'strings.dart';

Map<String, String> ${lowerName} = {
EOF

# Translation setup
get_lang_code() {
  case "$1" in
    Arabic|arabic) echo "ar" ;;
    Spanish|spanish) echo "es" ;;
    French|french) echo "fr" ;;
    Greek|greek) echo "el" ;;
    *) echo "auto" ;;
  esac
}

target_lang=$(get_lang_code "$langName")
counter=0
all_success=true

echo "🌐 Translating strings via free Google Translate..."
while IFS='|' read -r key value; do
  counter=$((counter+1))
  echo -ne "\r⏳ Translating [$counter/$total_strings]"

  # URL encode
  encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$value" 2>/dev/null || echo "$value")

  # Fetch translation
  translated=$(curl -sL --max-time 5 \
    -A "Mozilla/5.0" \
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${target_lang}&dt=t&q=${encoded}" | \
    grep -oP '\[\[\[".*?"' | head -1 | cut -d'"' -f2)

  # Fallback
  if [ -z "$translated" ] || [ "$translated" == "$value" ]; then
    translated="$value"  # Keep English if fails
    all_success=false
    echo "  // TODO: Translate $key"
  fi

  # Escape single quotes
  escaped=$(echo "$translated" | sed "s/'/\\\\'/g")
  echo "  Strings.$key: '$escaped'," >> "$LANG_FILE"

  sleep 0.2
done < "$temp_file"

cat >> "$LANG_FILE" <<EOF
};
EOF

rm "$temp_file"

echo ""
if [ "$all_success" = true ]; then
  echo "✅ All strings translated successfully!"
else
  echo "⚠️ Some strings need manual translation (marked with // TODO)"
fi

echo ""
echo "📁 Language File Created: $LANG_FILE"
echo "📊 Total Strings: $(grep -c "Strings\." "$LANG_FILE")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
