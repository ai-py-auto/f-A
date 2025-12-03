#!/usr/bin/env bash

echo "📁 Creating Common Widget in structure..."

BASE_DIR="lib"

# Create necessary directories first
mkdir -p "$BASE_DIR/core/widgets"

# basic_import.dart
cat > "$BASE_DIR/auth_app_bar.dart" <<EOF

import '../core/utils/basic_import.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;

  // Optional colors & styles
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool isPrimary;

  // Existing skip flag
  final bool isSkip;

  // ✅ Optional custom actions
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
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: isBack
          ? InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radius), // radius
              onTap: () => Get.back(),
              child: Icon(
                Icons.arrow_back_ios,
                color:
                    iconColor ??
                    (isPrimary
                        ? CustomColors.primary
                        : CustomColors.blackColor),
              ),
            )
          : null,
      title: TextWidget(
        title,
        color:
            titleColor ??
            (isPrimary ? CustomColors.primary : CustomColors.blackColor),
        fontSize: Dimensions.titleMedium * 1.2,
        fontWeight: FontWeight.w600,
      ),
      actions: [
        // ✅ Show Skip if isSkip is true
        if (isSkip)
          InkWell(
            onTap: () {
              // default skip action
              // Get.offAllNamed(Routes.welcomeScreen);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
              ),
              child: TextWidget(
                'Skip',
                color: CustomColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        if (actions != null) ...actions!,
      ],
    );
  }
}
EOF




# cat > "$BASE_DIR/text_widget.dart" <<EOF


# EOF



# a
cat > "$BASE_DIR/text_widget.dart" <<EOF

import 'package:shadify/shadify.dart';
import '../core/utils/basic_import.dart';

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
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: padding,
          child: Text(
            text,
            textAlign: textAlign,
            overflow: textOverflow,
            maxLines: maxLines,
            style:
                style ??
                TextStyle(
                  color: color ?? CustomColors.blackColor,
                  fontSize: fontSize ?? Dimensions.titleMedium, // already .sp
                  fontWeight: fontWeight,
                ),
          ),
        ),
      ),
    ).withShadifyLoading(loading: isLoading ?? false);
  }
}
EOF
