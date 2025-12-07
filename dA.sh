#!/usr/bin/env bash

MODE=$1  
GEN_FILE="lib/gen/assets.gen.dart"
PUBSPEC_FILE="pubspec.yaml"

echo "🚀 FlutterGen Smart Asset Cleaner"
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

# Check if gen file exists
if [ ! -f "$GEN_FILE" ]; then
  echo "❌ Error: $GEN_FILE not found!"
  echo "   Run 'flutter pub run build_runner build' first"
  exit 1
fi


# Extract asset names from gen file (get freeShippingAmico1 => ...)
GEN_ASSETS=$(grep -oE "get [a-zA-Z0-9_]+ =>" "$GEN_FILE" | awk '{print $2}' | sort | uniq)


# --- Step 2: Find used assets in Dart code ---
echo "🔍 Scanning  folder for asset usage..."


# --- Step 3: Find unused assets ---
echo "🔎 Analyzing unused assets..."
echo ""

UNUSED_ASSETS=()
UNUSED_COUNT=0

for ASSET in $GEN_ASSETS; do
  IS_USED=false
  
  # Check if this asset is used in code
  echo "$USED_ASSETS" | grep -qw "$ASSET" && IS_USED=true
  
  if [ "$IS_USED" = false ]; then
    UNUSED_ASSETS+=("$ASSET")
    ((UNUSED_COUNT++))
    
    # Find the file path for this asset from gen file
    FILE_PATH=$(grep -A 1 "get $ASSET =>" "$GEN_FILE" | grep -oE "'assets/[^']+'" | tr -d "'")
    
    echo "❌ Unused: $ASSET"
    echo "   File: $FILE_PATH"
    echo ""
  fi
done

# --- Step 4: Remove unused assets ---
if [ $UNUSED_COUNT -eq 0 ]; then
  echo "✨ All assets are being used! Nothing to clean."
  exit 0
fi

if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Dry Run Mode - No changes made"
  echo ""
  echo "💡 To remove unused assets, run:"
  echo "   $0 delete"
  echo ""
  
elif [ "$MODE" == "delete" ]; then
  echo "🗑️  Starting cleanup..."
  echo ""
  
  DELETED_FILES=0
  DELETED_PUBSPEC=0
  
  for ASSET in "${UNUSED_ASSETS[@]}"; do
    # Get file path from gen file
    FILE_PATH=$(grep -A 1 "get $ASSET =>" "$GEN_FILE" | grep -oE "'assets/[^']+'" | tr -d "'")
    
    if [ -n "$FILE_PATH" ]; then
      # Delete physical file
      if [ -f "$FILE_PATH" ]; then
        echo "🗑️  Deleting file: $FILE_PATH"
        rm -f "$FILE_PATH"
        ((DELETED_FILES++))
      fi
      
      # Remove from pubspec.yaml
      if grep -q "$FILE_PATH" "$PUBSPEC_FILE" 2>/dev/null; then
        echo "📝 Removing from pubspec.yaml: $FILE_PATH"
        
        # Create backup
        cp "$PUBSPEC_FILE" "${PUBSPEC_FILE}.backup"
        
        # Remove the line containing this asset path
        sed -i.tmp "/$FILE_PATH/d" "$PUBSPEC_FILE"
        rm -f "${PUBSPEC_FILE}.tmp"
        
        ((DELETED_PUBSPEC++))
      fi
    fi
  done
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Cleanup Complete!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  flutter pub run build_runner build --delete-conflicting-outputs
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ ✅ All done! Your project is now clean."
    echo ""

fi
