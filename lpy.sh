#!/usr/bin/env bash

read -p "🌍 Enter Language Name (example: Arabic, Spanish, Greek): " langName

if [ -z "$langName" ]; then
  echo "❌ Language Name Required!"
  exit 1
fi

# Normalize
lowerName=$(echo "$langName" | tr '[:upper:]' '[:lower:]')

# Auto-generate language code from name
langCode="${lowerName:0:2}"

# Auto-generate country code (uppercase)
countryCode=$(echo "$langCode" | tr '[:lower:]' '[:upper:]')

echo "---------------------------------------------"
echo "🌐 Auto Detected:"
echo "Language Name: $langName"
echo "Language Code: $langCode"
echo "Country Code:  $countryCode"
echo "---------------------------------------------"

BASE_DIR="lib/core/languages"
mkdir -p "$BASE_DIR"

# Always ensure English file exists
englishJson="$BASE_DIR/en_US.json"
if [ ! -f "$englishJson" ]; then
cat > "$englishJson" <<EOF
{
  "hello": "Hello",
  "welcome": "Welcome",
  "logout": "Logout"
}
EOF
echo "🇺🇸 English file created."
fi

# Create language json
jsonFile="$BASE_DIR/${langCode}_${countryCode}.json"
cat > "$jsonFile" <<EOF
{
  "hello": "Hello in $langName",
  "welcome": "Welcome in $langName",
  "logout": "Logout in $langName"
}
EOF

echo "📄 Created JSON: $jsonFile"

# Create language Dart loader
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

echo "📄 Created Loader: $dartFile"

# Update localization.dart
localizationFile="lib/core/languages/localization.dart"
if [ ! -f "$localizationFile" ]; then
cat > "$localizationFile" <<EOF
import 'package:get/get.dart';
import 'language_en_US.dart';
EOF
fi

# Add import
if ! grep -q "language_${langCode}_${countryCode}.dart" "$localizationFile"; then
echo "import 'language_${langCode}_${countryCode}.dart';" >> "$localizationFile"
fi

# Add translations map
if ! grep -q "'$langCode'" "$localizationFile"; then
cat >> "$localizationFile" <<EOF

// Added automatically for $langName
final Map<String, Future<Map<String, String>>> appLanguages = {
  'en': Languageen_US.load(),
  '$langCode': Language${langCode}_${countryCode}.load(),
};
EOF
fi

echo "---------------------------------------------"
echo "✅ Added: $langName ($langCode-$countryCode)"
echo "---------------------------------------------"
