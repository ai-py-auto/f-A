#!/usr/bin/env bash


STRINGS_FILE="lib/core/languages/strings.dart"
OUTPUT_DIR="lib/core/languages"

echo "🛠️ Creating Multi Language Method..."
echo "======================================================"

# Check if strings.dart exists
if [ ! -f "$STRINGS_FILE" ]; then
    echo ""
    echo "❌ Error: $STRINGS_FILE not found!"
    echo "💡 Make sure you run this from your Flutter project root"
    echo ""
    exit 1
fi

# Ask for language name
echo ""
echo "🌍 Available Languages Examples:"
echo "   • English"
echo "   • Arabic (العربية)"
echo "   • Bengali (বাংলা)"
echo "   • Spanish (Español)"
echo "   • French (Français)"
echo "   • German (Deutsch)"
echo ""
read -p "📥 Enter language name: " LANGUAGE_NAME

# Validate input
if [ -z "$LANGUAGE_NAME" ]; then
    echo ""
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

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo ""
    echo "⚠️  File $OUTPUT_FILE already exists!"
    read -p "Do you want to overwrite it? (y/n): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo "❌ Aborted!"
        exit 0
    fi
fi

# Start building the output file
cat > "$OUTPUT_FILE" << EOF
import 'strings.dart';

Map<String, String> $LANGUAGE_LOWER = {
EOF

# Parse strings.dart and extract static const String declarations
# Track for statistics
ENTRY_COUNT=0
declare -A VALUE_MAP
DUPLICATES_FOUND=0

echo "✍️  Processing strings..."

while IFS= read -r line; do
    # Match lines like: static const String varName = "value";
    if echo "$line" | grep -qE '^\s*static\s+const\s+String\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*"'; then
        # Extract variable name
        VAR_NAME=$(echo "$line" | sed -E 's/.*static\s+const\s+String\s+([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
        
        # Extract value - handle multi-line and escaped quotes
        VAR_VALUE=$(echo "$line" | sed -E 's/.*=\s*"(.*)"\s*;.*/\1/')
        
        # Skip if empty
        if [ -z "$VAR_NAME" ] || [ -z "$VAR_VALUE" ]; then
            continue
        fi
        
        # Check for duplicates (for warning only)
        if [ -n "${VALUE_MAP[$VAR_VALUE]}" ]; then
            if [ $DUPLICATES_FOUND -eq 0 ]; then
                echo ""
                echo "⚠️  Duplicate values detected:"
            fi
            DUPLICATES_FOUND=1
            echo "   • '$VAR_VALUE' → $VAR_NAME, ${VALUE_MAP[$VAR_VALUE]}"
        fi
        VALUE_MAP["$VAR_VALUE"]="$VAR_NAME"
        
        # Escape single quotes for Dart
        VAR_VALUE=$(echo "$VAR_VALUE" | sed "s/'/\\\\'/g")
        
        # Write to output file
        echo "  Strings.$VAR_NAME: '$VAR_VALUE'," >> "$OUTPUT_FILE"
        
        ENTRY_COUNT=$((ENTRY_COUNT + 1))
    fi
done < "$STRINGS_FILE"

# Close the map
echo "};" >> "$OUTPUT_FILE"

# Print results
echo ""
echo "======================================================"
echo "✅ Successfully created $OUTPUT_FILE"
echo "📝 Total entries: $ENTRY_COUNT"
echo "🎉 Language '$LANGUAGE_NAME' file is ready!"
echo ""

if [ $DUPLICATES_FOUND -eq 1 ]; then
    echo "⚠️  Warning: Duplicate values detected above!"
    echo "💡 These may cause 'duplicate key' errors in Dart"
    echo "💡 Fix: Remove duplicate keys from strings.dart"
    echo ""
fi

echo "📌 Next Steps:"
echo "   1. Translate values in: $OUTPUT_FILE"
echo "   2. Import in your app: import 'package:yourapp/core/languages/${LANGUAGE_LOWER}.dart';"
echo ""
echo "🎯 Usage Example:"
echo "   String text = ${LANGUAGE_LOWER}[Strings.login] ?? 'Login';"
echo ""
