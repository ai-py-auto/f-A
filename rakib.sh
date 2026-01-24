#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════════════════
#                           🚀 PROJECT SETUP GUIDE
# ═══════════════════════════════════════════════════════════════════════════
#
#  Step 1️⃣   chmod +x rakib.sh
#  Step 2️⃣   ./rakib.sh make-str
#  Step 3️⃣   ./rakib.sh write-widgets
#  Step 4️⃣   ./rakib.sh make-views
#  Step 5️⃣   ./rakib.sh clean-yaml
#  Step 6️⃣   dart run build_runner build
#  Step 7️⃣   flutter clean && flutter pub get && flutter run
#
# ═══════════════════════════════════════════════════════════════════════════

#flutter clean
#flutter pub get
#cd android
#./gradlew clean
#./gradlew --stop
#cd ..
#flutter run

# ─────────────────────────────────────────────────────────────────────────

# flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi

# ─────────────────────────────────────────────────────────────────────────

# flutter clean && flutter pub get && cd android && ./gradlew clean && ./gradlew --stop && cd .. && flutter pub get && flutter run

# ─────────────────────────────────────────────────────────────────────────

# keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# keytool -list -v -keystore android/app/my-release-key.jks -alias my-key-alias


# ═══════════════════════════════════════════════════════════════════════════




case "$1" in

    "make-strings")
      echo "🛠️ Running Figma Strings Extractor..."
      # shellcheck disable=SC2162
      read -p "📥 Enter Figma File ID: " FILE_ID
      # shellcheck disable=SC2162
      read -p "🔑 Enter Personal Access Token: " TOKEN

      tmpScript=$(mktemp /tmp/figma_strings_XXXXXX.py)
      if curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/fs.py -o "$tmpScript"; then
          echo "🚀 Running Python script..."
          python3 "$tmpScript" "$FILE_ID" "$TOKEN"
          rm -f "$tmpScript"
      else
          echo "❌ Failed to download script!"
          rm -f "$tmpScript"
          exit 1
      fi
      ;;

  "make-str")
    echo "🛠️ Creating Flutter project folder structure..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/cs.sh | bash
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/cu.sh | bash
    ;;

  "write-widgets")
    echo "🛠️ Creating Common widget structure..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/cw.sh | bash
    ;;
    "make-model")
      echo "📥  Auto-Model Creating..."
      tmpScript=$(mktemp /tmp/auto_model_XXXXXX.sh)
      if curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/mA.sh -o "$tmpScript"; then
          chmod +x "$tmpScript"
          echo "🚀 Running Auto-Model Script..."
          bash "$tmpScript"
          rm -f "$tmpScript"
      else
          echo "❌ Failed to Auto-Model script!"
          rm -f "$tmpScript"
          exit 1
      fi
      ;;

  "make-views")
    # shellcheck disable=SC2162
    read -p "📥 Enter View Names (space-separated): " viewNames
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/vv.sh | bash -s "$viewNames"
    ;;

  "clean-yaml")
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Name: " projectName
    # shellcheck disable=SC2162
    read -p "📥 Enter Project Description: " projectDescription
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/ml.sh | bash -s "$projectName" "$projectDescription"
    ;;

  "make-widget")
    # shellcheck disable=SC2162
    read -p "📥 Enter View Name: " viewName
    # shellcheck disable=SC2162
    read -p "📥 Enter Widget Names (space-separated): " widgetNames
    IFS=' ' read -r -a widgetArray <<< "$widgetNames"
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/widt.sh | bash -s "$viewName" "${widgetArray[@]}"
    ;;

  "api-method")
    echo "🛠️ Creating API Method..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/am.sh | bash
    ;;

  "language-en")
    echo "🛠️ Creating API Method..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/lpy.sh | bash
    ;;

  "setup-firebase")
    echo "📥 Starting Firebase setup ..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/frbs.sh -o frbs.sh
    chmod +x frbs.sh
    echo "🚀 Running Firebase setup..."
    ./frbs.sh
    ;;
  #    "make-strings")
  #      echo "🛠️ Running Figma Strings Extractor..."
  #      # shellcheck disable=SC2162
  #      read -p "📥 Enter Figma File ID: " FILE_ID
  #      # shellcheck disable=SC2162
  #      read -p "🔑 Enter Personal Access Token: " TOKEN
  #
  #      tmpScript=$(mktemp /tmp/figma_strings_XXXXXX.py)
  #      if curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/fScli.py -o "$tmpScript"; then
  #          echo "🚀 Running Python script..."
  #          python3 "$tmpScript" "$FILE_ID" "$TOKEN"
  #          rm -f "$tmpScript"
  #      else
  #          echo "❌ Failed to download script!"
  #          rm -f "$tmpScript"
  #          exit 1
  #      fi
  #      ;;
  "make-shaKey")
    echo "🛠️ Generating SHA key..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/sa.sh | bash
    ;;

  "delete-unused-assets")
    echo "🧹 Deleting unused assets..."
    curl -sSL https://raw.githubusercontent.co m/ai-py-auto/f-A/refs/heads/main/dA.sh | bash -s delete
    #dart run build_runner build
    ;;
  "delete-unused-strings")
    echo "🧹 Deleting unused assets..."
    curl -sSL https://raw.githubusercontent.com/ai-py-auto/f-A/refs/heads/main/unS.sh | bash -s delete
    #dart run build_runner build
    ;;

  "help")
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║              📚 RAKIB.SH - AVAILABLE COMMANDS                      ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🏗️  PROJECT STRUCTURE"
    echo "  └─ make-str                    Create project folder structure"
    echo "  └─ write-widgets               Create common widget structure"
    echo ""
    echo "🎨 UI COMPONENTS"
    echo "  └─ make-views                  Create new views"
    echo "  └─ make-widget                 Create custom widgets"
    echo ""
    echo "📦 PROJECT MANAGEMENT"
    echo "  └─ clean-yaml                  Clean pubspec.yaml"
    echo "  └─ make-model                  Generate data models"
    echo ""
    echo "🌐 API & LOCALIZATION"
    echo "  └─ api-method                  Create API methods"
    echo "  └─ language-en                 Generate language translation files"
    echo "  └─ make-strings                Extract strings from Figma"
    echo ""
    echo "🔥 FIREBASE & SECURITY"
    echo "  └─ setup-firebase              Setup Firebase configuration"
    echo "  └─ make-shaKey                 Generate SHA key"
    echo ""
    echo "🧹 CLEANUP UTILITIES"
    echo "  └─ delete-unused-assets        Delete unused assets"
    echo "  └─ delete-unused-strings       Delete unused strings"
    echo ""
    echo "📖 HELP"
    echo "  └─ help                        Show this help message"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    ;;

  *)
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    ⚠️  INVALID COMMAND                            ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📝 Usage Examples:"
    echo "  ./rakib.sh make-str"
    echo "  ./rakib.sh write-widgets"
    echo "  ./rakib.sh make-views"
    echo "  ./rakib.sh clean-yaml"
    echo "  ./rakib.sh make-widget"
    echo "  ./rakib.sh make-model"
    echo "  ./rakib.sh api-method"
    echo "  ./rakib.sh language-en"
    echo "  ./rakib.sh make-strings"
    echo "  ./rakib.sh setup-firebase"
    echo "  ./rakib.sh make-shaKey"
    echo "  ./rakib.sh delete-unused-assets"
    echo "  ./rakib.sh delete-unused-strings"
    echo ""
    echo "💡 Tip: Run './rakib.sh help' to see all available commands"
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    ;;
esac
