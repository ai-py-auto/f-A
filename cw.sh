#!/usr/bin/env bash

##########################
#  HACKING PRINT EFFECT  #
##########################
type_effect () {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.015
    done
    echo ""
}

clear
echo ""
type_effect "🟩 SYSTEM BREACHED..."
sleep 0.3
type_effect "🟩 ACCESSING TARGET DIRECTORY..."
sleep 0.3
type_effect "🟩 INITIATING WIDGETS INJECTION..."
sleep 0.5
echo ""

##############################################
#        CREATE CORE/WIDGETS IF MISSING      #
##############################################

echo ""
BASE_DIR="lib/core/widgets"

if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
    type_effect "📂 Creating directory: $BASE_DIR"
else
    type_effect "📂 Directory already exists: $BASE_DIR"
fi

sleep 0.3
echo ""
type_effect "🛠 Installing file: common_app_bar.dart"

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

sleep 0.5
echo ""
type_effect "🛠 Installing file: text_widget.dart"

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

sleep 0.5
echo ""
type_effect "✔ FILES SUCCESSFULLY INJECTED"
sleep 0.3
type_effect "✔ WIDGETS DEPLOYMENT COMPLETE"
sleep 0.3
type_effect "🟩 EXITING SYSTEM..."
sleep 0.3
echo ""
