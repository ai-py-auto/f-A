#!/usr/bin/env bash
# =========================================
# FlutterGen Smart Asset Cleaner (Fixed)
# =========================================

MODE=$1   # dry-run / delete

# ✅ Folders to scan
ASSET_FOLDERS=("assets/icons" "assets/logo" "assets/dummy")

# ✅ Assets to always keep (even if not found in code)
KEEP_REFERENCES=(
  "notification"
  "appLogo"
)

echo "🚀 FlutterGen Asset Cleaner (Fixed Version)"
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

# --- Step 1: Collect all asset references from Dart code ---
echo "🔍 Scanning Dart files for asset references..."

# Extract all Assets.xxx references (with or without .path)
USED_ASSETS=$(grep -rhoE "Assets\.(icons|logo|dummy)\.[A-Za-z0-9_]+(\.path)?" lib 2>/dev/null | \
  sed 's/Assets\.\(icons\|logo\|dummy\)\.\([A-Za-z0-9_]*\).*/\2/' | \
  sort | uniq)

if [ -z "$USED_ASSETS" ]; then
  echo "⚠️  No asset references found in lib folder"
fi

echo "📝 Found asset references:"
echo "$USED_ASSETS" | sed 's/^/   - /'
echo ""

UNUSED_COUNT=0
DELETED_COUNT=0
TOTAL_COUNT=0

# --- Step 2: Loop through all asset files ---
for FOLDER in "${ASSET_FOLDERS[@]}"; do
  if [ ! -d "$FOLDER" ]; then
    echo "⚠️  Folder $FOLDER not found, skipping..."
    continue
  fi
  
  echo "📁 Scanning folder: $FOLDER"
  
  find "$FOLDER" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" -o -name "*.webp" \) | while read FILE; do
    ((TOTAL_COUNT++))
    
    # Get filename without extension (FlutterGen uses this as reference name)
    FILE_BASENAME=$(basename "$FILE")
    FILE_NAME="${FILE_BASENAME%.*}"
    
    # Convert to camelCase if needed (FlutterGen converts snake_case to camelCase)
    # e.g., free_shipping_amico1 -> freeShippingAmico1
    CAMEL_CASE_NAME=$(echo "$FILE_NAME" | perl -pe 's/_([a-z])/\U$1/g')
    
    KEEP=false
    REASON=""
    
    # Check if in KEEP_REFERENCES
    for KEEP_REF in "${KEEP_REFERENCES[@]}"; do
      if [[ "$FILE_NAME" == *"$KEEP_REF"* ]] || [[ "$CAMEL_CASE_NAME" == *"$KEEP_REF"* ]]; then
        KEEP=true
        REASON="(in keep list)"
        break
      fi
    done
    
    # Check if used in code
    if [ "$KEEP" = false ]; then
      echo "$USED_ASSETS" | grep -qw "$FILE_NAME" && KEEP=true && REASON="(used in code)"
      echo "$USED_ASSETS" | grep -qw "$CAMEL_CASE_NAME" && KEEP=true && REASON="(used in code)"
    fi
    
    # Delete if not used
    if [ "$KEEP" = false ]; then
      ((UNUSED_COUNT++))
      if [ "$MODE" == "dry-run" ]; then
        echo "   ❌ Unused: $FILE"
      elif [ "$MODE" == "delete" ]; then
        echo "   🗑️  Deleting: $FILE"
        rm -f "$FILE"
        ((DELETED_COUNT++))
      fi
    else
      if [ "$MODE" == "dry-run" ]; then
        echo "   ✅ Keep: $FILE_BASENAME $REASON"
      fi
    fi
  done
  echo ""
done

# --- Step 3: Summary ---
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$MODE" == "dry-run" ]; then
  echo "🔍 Dry Run Complete"
  echo "   Total assets scanned: $TOTAL_COUNT"
  echo "   Unused assets found: $UNUSED_COUNT"
  echo ""
  echo "💡 Run with 'delete' mode to remove unused assets:"
  echo "   $0 delete"
else
  echo "✅ Cleanup Complete"
  echo "   Total assets scanned: $TOTAL_COUNT"
  echo "   Deleted: $DELETED_COUNT unused assets"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
