#!/bin/bash

STRINGS_FILE="lib/core/languages/strings.dart"
OUTPUT_DIR="lib/core/languages"
OUTPUT_FILE="$OUTPUT_DIR/english.dart"

echo "🛠️ Creating Multi Language Method..."

# Check if strings.dart exists
if [ ! -f "$STRINGS_FILE" ]; then
    echo "❌ Error: $STRINGS_FILE not found!"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Start building the output file
cat > "$OUTPUT_FILE" << 'EOF'
import 'strings.dart';

Map<String, String> english = {
EOF

# Parse strings.dart and extract static const String declarations
grep -E '^\s*static const String [a-zA-Z_][a-zA-Z0-9_]*\s*=\s*".*";' "$STRINGS_FILE" | while IFS= read -r line; do
    # Extract variable name and value
    var_name=$(echo "$line" | sed -E 's/.*static const String ([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
    var_value=$(echo "$line" | sed -E 's/.*=\s*"(.*)";.*/\1/')
    
    # Escape single quotes in the value
    var_value=$(echo "$var_value" | sed "s/'/\\\\'/g")
    
    # Write to output file
    echo "  Strings.$var_name: '$var_value'," >> "$OUTPUT_FILE"
done

# Close the map
echo "};" >> "$OUTPUT_FILE"

echo "✅ Successfully created $OUTPUT_FILE"
echo "✅ Successfully created $OUTPUT_FILE"
echo "📝 Total entries: $(grep -c "Strings\." "$OUTPUT_FILE")"
