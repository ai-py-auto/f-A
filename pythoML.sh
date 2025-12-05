#!/bin/bash

# Multi-language generator script
# Generates language files from strings.dart

STRINGS_FILE="lib/core/languages/strings.dart"
OUTPUT_DIR="lib/core/languages"

echo "🛠️ Creating Multi Language Method..."
echo "=================================================="

# Check if strings.dart exists
if [ ! -f "$STRINGS_FILE" ]; then
    echo "❌ Error: $STRINGS_FILE not found!"
    exit 1
fi

# Ask for language name
echo ""
echo "🌍 Enter the language name (e.g., English, Arabic, Bengali, Spanish):"
read -p "Language: " LANGUAGE_NAME

# Validate input
if [ -z "$LANGUAGE_NAME" ]; then
    echo "❌ Language name cannot be empty!"
    exit 1
fi

# Convert to lowercase for filename
LANGUAGE_LOWER=$(echo "$LANGUAGE_NAME" | tr '[:upper:]' '[:lower:]')
OUTPUT_FILE="$OUTPUT_DIR/${LANGUAGE_LOWER}.dart"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo ""
echo "📖 Reading $STRINGS_FILE..."

# Start building the output file
cat > "$OUTPUT_FILE" << EOF
import 'strings.dart';

Map<String, String> $LANGUAGE_LOWER = {
EOF

# Parse strings.dart and extract static const String declarations
# Track duplicates
declare -A VALUE_MAP
DUPLICATES_FOUND=0

while IFS= read -r line; do
    # Match lines like: static const String varName = "value";
    if echo "$line" | grep -qE '^\s*static\s+const\s+String\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*".*"'; then
        # Extract variable name
        VAR_NAME=$(echo "$line" | sed -E 's/.*static\s+const\s+String\s+([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
        
        # Extract value (handle quotes and escaped characters)
        VAR_VALUE=$(echo "$line" | sed -E 's/.*=\s*"(.*)"\s*;.*/\1/')
        
        # Check for duplicates
        if [ -n "${VALUE_MAP[$VAR_VALUE]}" ]; then
            DUPLICATES_FOUND=1
            echo "⚠️  Duplicate: '$VAR_VALUE' → $VAR_NAME, ${VALUE_MAP[$VAR_VALUE]}"
        fi
        VALUE_MAP["$VAR_VALUE"]="$VAR_NAME"
        
        # Escape single quotes for Dart
        VAR_VALUE=$(echo "$VAR_VALUE" | sed "s/'/\\\\'/g")
        
        # Write to output file
        echo "  Strings.$VAR_NAME: '$VAR_VALUE'," >> "$OUTPUT_FILE"
    fi
done < "$STRINGS_FILE"

# Close the map
echo "};" >> "$OUTPUT_FILE"

# Count entries
ENTRY_COUNT=$(grep -c "Strings\." "$OUTPUT_FILE")

echo ""
echo "✍️  Generating $OUTPUT_FILE..."
echo ""
echo "✅ Successfully created $OUTPUT_FILE"
echo "📝 Total entries: $ENTRY_COUNT"
echo "🎉 Language '$LANGUAGE_NAME' file is ready!"

if [ $DUPLICATES_FOUND -eq 1 ]; then
    echo ""
    echo "⚠️  Warning: Duplicate values detected above!"
    echo "💡 Fix: Remove duplicate keys from strings.dart"
fi

echo ""
