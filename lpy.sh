#!/usr/bin/env bash

langCode="$1"
countryCode="$2"
langName="$3"

if [ -z "$langCode" ] || [ -z "$countryCode" ] || [ -z "$langName" ]; then
  echo "❌ Missing parameters!"
  echo "Usage: lpy.sh <langCode> <countryCode> <Language Name>"
  exit 1
fi

BASE_DIR="lib/core/languages"

mkdir -p "$BASE_DIR"

jsonFile="$BASE_DIR/${langCode}_${countryCode}.json"
dartFile="$BASE_DIR/language_${langCode}_${countryCode}.dart"

echo "🔧 Creating JSON: $jsonFile"
cat > "$jsonFile" <<EOF
{
  "hello": "Hello in $langName"
}
EOF

echo "🔧 Creating Dart file: $dartFile"
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

localizationFile="lib/core/languages/localization.dart"

if [ -f "$localizationFile" ]; then
  echo "🔧 Updating localization.dart"

  if ! grep -q "Locale('$langCode'" "$localizationFile"; then
cat >> "$localizationFile" <<EOF

    // Added automatically for $langName
    '$langCode': Language${langCode}_${countryCode}.load(),
EOF
  fi
fi

echo "✅ Language added: $langName ($langCode-$countryCode)"
