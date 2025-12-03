#!/usr/bin/env bash

# ==========================
# HACKER CONSOLE FUNCTIONS
# ==========================

colors=(
  $(tput setaf 1)  # red
  $(tput setaf 2)  # green
  $(tput setaf 3)  # yellow
  $(tput setaf 4)  # blue
  $(tput setaf 5)  # magenta
  $(tput setaf 6)  # cyan
)
reset=$(tput sgr0)

random_color() {
  echo -n "${colors[$RANDOM % ${#colors[@]}]}"
}

type_effect () {
    text="$1"
    lineColor=$(random_color)
    for ((i=0; i<${#text}; i++)); do
        echo -n "${lineColor}${text:$i:1}${reset}"
        sleep 0.001   # SUPER FAST typing
    done
    echo ""
}

spinner() {
    local pid=$!
    local delay=0.08
    local spin="|/-\\"
    while ps -p $pid > /dev/null; do
        local spcolor=$(random_color)
        for i in $(seq 0 3); do
            echo -ne "${spcolor}[${spin:$i:1}] Installing...${reset}\r"
            sleep $delay
        done
    done
    echo -ne "                          \r"
}

clear
echo ""

type_effect "███ HACKING WIDGETS SUBSYSTEM ███"
type_effect ">>> Establishing secure SSH tunnel..."
sleep 0.2
type_effect ">>> Injecting files into Flutter core..."
sleep 0.2
echo ""

BASE_DIR="lib/core/widgets"

(
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
fi
) & spinner

echo ""
type_effect "✔ Directory verified: $BASE_DIR"
sleep 0.1

type_effect ">>> Writing: common_app_bar.dart"
sleep 0.15

cat > "$BASE_DIR/common_app_bar.dart" <<EOF
import '../utils/basic_import.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool isPrimary;
  final bool isSkip;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.isBack = true,
    this.isPrimary = false,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.isSkip = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: isBack
          ? InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                color: iconColor ?? (isPrimary ? Colors.blue : Colors.black),
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? (isPrimary ? Colors.blue : Colors.black),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (isSkip)
          InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }
}
EOF

sleep 0.15
type_effect "✔ common_app_bar.dart injected"
sleep 0.1

type_effect ">>> Writing: text_widget.dart"
sleep 0.15

cat > "$BASE_DIR/text_widget.dart" <<EOF
import 'package:flutter/material.dart';
import '../utils/basic_import.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
    this.text, {
    super.key,
    this.textAlign,
    this.textOverflow,
    this.padding = EdgeInsets.zero,
    this.opacity = 1.0,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.onTap,
    this.isLoading,
  });

  final String text;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? style;
  final VoidCallback? onTap;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: padding,
        child: Text(
          text,
          textAlign: textAlign,
          overflow: textOverflow,
          maxLines: maxLines,
          style: style ??
              TextStyle(
                color: color ?? Colors.black,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight,
              ),
        ),
      ),
    );
  }
}
EOF

sleep 0.15
type_effect "✔ text_widget.dart injected"
sleep 0.1

echo ""
type_effect ">>> Finalizing..."
sleep 0.15
type_effect ">>> Clearing traces..."
sleep 0.1
type_effect ">>> Logging out..."

sleep 0.3
echo ""
type_effect "███ OPERATION COMPLETED — SYSTEM SECURE ███"
echo ""
