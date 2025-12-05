#!/usr/bin/env bash

langName="$1"

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  exit 1
fi

# normalize input
lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

# auto-detect language code (first 2 letters)
langCode="${lowerName:0:2}"

# auto country code (uppercase)
countryCode=$(echo "$langCode" | tr '[:lower:]' '[:upper:]')

echo "---------------------------------------------"
echo "🌍 Adding Language:"
echo "Language : $langName"
echo "LangCode : $langCode"
echo "Country  : $countryCode"
echo "---------------------------------------------"

BASE_DIR="lib/core/languages"
mkdir -p "$BASE_DIR"

# English always exists
englishJson="$BASE_DIR/en_US.json"
if [ ! -f "$englishJson" ]; then
cat > "$englishJson" <<EOF
{
  "hello": "Hello",
  "welcome": "Welcome"
}
EOF
echo "✔ English file created"
fi

# Create new language JSON
jsonFile="$BASE_DIR/${langCode}_${countryCode}.json"
cat > "$jsonFile" <<EOF
{
  "hello": "Hello in $langName",
  "welcome": "Welcome in $langName"
}
EOF

echo "✔ Created $jsonFile"

# Create loader Dart file
dartFile="$BASE_DIR/language_${langCode}_${countryCode}.dart"
cat > "$dartFile" <<EOF
import 'dart:convert';
import 'package:flutter/services.dart';

class Language${langCode}_${countryCode} {
  static Future<Map<String, String>> load() async {
    final jsonString =
        await rootBundle.loadString('core/languages/${langCode}_${countryCode}.json');
    return Map<String, String>.from(json.decode(jsonString));
  }
}
EOF

echo "✔ Created $dartFile"

# Update localization.dart
localization="lib/core/languages/localization.dart"

if [ ! -f "$localization" ]; then
cat > "$localization" <<EOF
import 'package:get/get.dart';
import 'language_en_US.dart';

final Map<String, Future<Map<String, String>>> appLanguages = {
  'en': Languageen_US.load(),
};
EOF
fi

# add import
if ! grep -q "language_${langCode}_${countryCode}.dart" "$localization"; then
echo "import 'language_${langCode}_${countryCode}.dart';" >> "$localization"
fi

# add language map entry
if ! grep -q "'$langCode'" "$localization"; then
sed -i "/appLanguages = {/a\  '$langCode': Language${langCode}_${countryCode}.load()," "$localization"
fi

echo "---------------------------------------------"
echo "✅ Language Added Successfully: $langName"
echo "---------------------------------------------"
