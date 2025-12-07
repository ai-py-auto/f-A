#!/usr/bin/env bash
# =========================================
# Flutter Unused Strings Cleaner
# Removes unused string constants from Strings class
# =========================================

MODE=$1   # dry-run / delete
STRINGS_FILE="lib/core/languages/strings.dart"

echo "🚀 Flutter Unused Strings Cleaner"
echo "Mode: ${MODE:-dry-run}"
echo ""

# Validate mode
if [ -z "$MODE" ]; then
  echo "⚠️  No mode specified. Using 'dry-run' by default."
  MODE="dry-run"
fi

if [ "$MODE" != "dry-run" ] && [ "$MODE" != "delete" ]; then
  echo "❌ Invalid mode: $MODE"
  echo "Usage: $0 [dry-run|delete]"
  exit 1
fi

# Check if strings file exists
if [ ! -f "$STRINGS_FILE" ]; then
  echo "❌ Error: $STRINGS_FILE not found!"
  exit 1
fi

# --- Step 1: Extract all string constants from Strings class ---
echo "📖 Reading string constants from $STRINGS_FILE..."

# Extract string variable names (static String xxx = or static const String xxx =)
ALL_STRINGS=$(grep -oE "static (const )?String [a-zA-Z0-9_]+ =" "$STRINGS_FILE" | \
  awk '{print $(NF-1)}' | sort | uniq)

TOTAL_STRINGS=$(echo "$ALL_STRINGS" | wc -l | tr -d ' ')
echo "📝 Found $TOTAL_STRINGS string constants in Strings class"
echo ""

# --- Step 2: Find used strings in Dart code (excluding the strings.dart file itself) ---
echo "🔍 Scanning lib folder for string usage..."

# Find all Strings.xxx usage in dart files (excluding strings.dart)
USED_STRINGS=$(grep -rh "Strings\.[a-zA-Z0-9_]\+" lib \
  --include="*.dart" \
  --exclude="strings.dart" 2>/dev/null | \
  grep -oE "Strings\.[a-zA-Z0-9_]+" | \
  sed 's/Strings\.\([a-zA-Z0-9_]*\).*/\1/' | \
  sort | uniq)

USED_COUNT=$(echo "$USED_STRINGS" | grep -v "^$" | wc -l | tr -d ' ')
echo "📝 Found $USED_COUNT string references in code"
echo ""

# --- Step 3: Find unused strings ---
echo "🔎 Analyzing unused strings..."
echo ""

UNUSED_STRINGS=()
UNUSED_COUNT=0

for STRING in $ALL_STRINGS; do
  IS_USED=false
  
  # Check if this string is used in code
  echo "$USED_STRINGS" | grep -qw "$STRING" && IS_USED=true
  
  if [ "$IS_USED" = false ]; then
    UNUSED_STRINGS+=("$STRING")
    ((UNUSED_COUNT++))
    
    # Get the full line from strings.dart
    STRING_LINE=$(grep "String $STRING =" "$STRINGS_FILE")
    
    echo "❌ Unused: $STRING"
    echo "   $STRING_LINE"
    echo ""
  fi
done

# --- Step 4: Summary and action ---
if [ $UNUSED_COUNT -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✨ All strings are being used! Nothing to clean."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary:"
echo "   Total strings: $TOTAL_STRINGS"
echo "   Used strings: $USED_COUNT"
echo "   Unused strings: $UNUSED_COUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Dry Run Mode - No changes made"
  echo ""
  echo "💡 To remove unused strings, run:"
  echo "   $0 delete"
  echo ""
  echo "⚠️  This will remove $UNUSED_COUNT unused string constants from:"
  echo "   $STRINGS_FILE"
  
elif [ "$MODE" == "delete" ]; then
  echo "🗑️  Starting cleanup..."
  echo ""
  
  # Create backup
  BACKUP_FILE="${STRINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$STRINGS_FILE" "$BACKUP_FILE"
  
  DELETED_COUNT=0
  
  # Create temporary file
  TEMP_FILE="${STRINGS_FILE}.tmp"
  
  # Read the file line by line
  while IFS= read -r line; do
    SHOULD_KEEP=true
    
    # Check if this line contains an unused string declaration
    for UNUSED in "${UNUSED_STRINGS[@]}"; do
      if echo "$line" | grep -q "String $UNUSED ="; then
        SHOULD_KEEP=false
        ((DELETED_COUNT++))
        break
      fi
    done
    
    # Keep the line if it's not an unused string
    if [ "$SHOULD_KEEP" = true ]; then
      echo "$line" >> "$TEMP_FILE"
    fi
  done < "$STRINGS_FILE"
  
  # Replace original file with cleaned version
  mv "$TEMP_FILE" "$STRINGS_FILE"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Cleanup Complete!"
  echo "   Removed: $DELETED_COUNT unused strings"
  echo "   Backup: $BACKUP_FILE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Auto format the file (silently)
  if command -v dart &> /dev/null; then
    dart format "$STRINGS_FILE" > /dev/null 2>&1
  fi
fi
