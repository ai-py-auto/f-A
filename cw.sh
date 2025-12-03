#!/usr/bin/env bash

green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

colors=("$green" "$yellow" "$blue" "$magenta" "$cyan")

random_color() {
  echo -n "${colors[$RANDOM % ${#colors[@]}]}"
}

intro_effect () {
    text="$1"
    lineColor=$(random_color)
    for ((i=0; i<${#text}; i++)); do
        echo -n "${lineColor}${text:$i:1}${reset}"
        sleep 0.002
    done
    echo ""
}

outro_effect () {
    text="$1"
    lineColor=$(random_color)
    for ((i=0; i<${#text}; i++)); do
        echo -n "${lineColor}${text:$i:1}${reset}"
        sleep 0.002
    done
    echo ""
}

clear
echo ""

intro_effect "███ INITIALIZING SYSTEM ███"
intro_effect ">>> ESTABLISHING SECURE TERMINAL..."
echo ""
echo ""

echo "Checking directory..."
BASE_DIR="lib/core/widgets"
mkdir -p "$BASE_DIR"




















cat > "$BASE_DIR/common_app_bar.dart" <<EOF
import '../utils/basic_import.dart';

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

echo "Writing: text_widget.dart"
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

echo "Writing: primary_button_widget.dart"
cat > "$BASE_DIR/primary_button_widget.dart" <<EOF
import '../core/utils/basic_import.dart';
import 'loading_widget.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double borderWidth;
  final double? height;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final OutlinedBorder? shape;
  final Widget? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final bool primary;
  final bool disable;
  final bool outlineButton; // new flag for outline button
  final EdgeInsets? padding;

  PrimaryButtonWidget({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColor,
    this.borderWidth = 0,
    this.height,
    this.buttonColor,
    this.buttonTextColor,
    this.shape,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.primary = false,
    this.disable = false,
    this.outlineButton = false, // default false
    this.padding,
  });

  final ValueNotifier<bool> isPadding = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LoadingWidget();

    return ValueListenableBuilder<bool>(
      valueListenable: isPadding,
      builder: (context, isPadded, _) {
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: isPadded ? 5 : 0),
            height: height ?? Dimensions.buttonHeight * 0.85,
            width: double.infinity,
            child: outlineButton
                ? OutlinedButton(
                    onPressed: disable
                        ? null
                        : () {
                            isPadding.value = true;
                            Future.delayed(
                              const Duration(milliseconds: 220),
                              () {
                                isPadding.value = false;
                              },
                            );
                            onPressed();
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: borderWidth,
                        color: disable
                            ? CustomColors.disableColor
                            : borderColor ?? CustomColors.primary,
                      ),
                      shape:
                          shape ??
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 0.8,
                            ),
                          ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: TextWidget(
                      title,
                      fontSize: isPadded
                          ? (fontSize ?? Dimensions.titleMedium)
                          : fontSize ?? Dimensions.titleMedium * 1.1,
                      fontWeight: fontWeight ?? FontWeight.w900,
                      color: primary
                          ? CustomColors.primary
                          : buttonTextColor ?? CustomColors.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ElevatedButton(
                    onPressed: disable
                        ? null
                        : () {
                            isPadding.value = true;
                            Future.delayed(
                              const Duration(milliseconds: 220),
                              () {
                                isPadding.value = false;
                              },
                            );
                            onPressed();
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          (disable ? CustomColors.disableColor : buttonColor) ??
                          CustomColors.primary,
                      shape:
                          shape ??
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 0.8,
                            ),
                          ),
                      side: BorderSide(
                        width: borderWidth,
                        color: disable
                            ? CustomColors.disableColor
                            : borderColor ?? CustomColors.primary,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      child: TextWidget(
                        title,
                        fontSize: isPadded
                            ? (fontSize ?? Dimensions.titleMedium)
                            : fontSize ?? Dimensions.titleMedium * 1.1,
                        fontWeight: fontWeight ?? FontWeight.w900,
                        color: primary
                            ? CustomColors.primary
                            : buttonTextColor ?? Colors.white,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
EOF





































echo ""
echo "✔ All widgets created."
echo "✔ Directory verified: $BASE_DIR"
echo ""






echo ""
outro_effect ">>> CLEARING ACCESS LOGS..."
outro_effect ">>> SECURE EXIT..."
outro_effect "███ SYSTEM SHUTDOWN — SAFE ███"
echo ""
