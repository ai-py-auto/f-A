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
      scrolledUnderElevation: 0,
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

cat > "$BASE_DIR/primary_button_widget.dart" <<EOF
import '../utils/basic_import.dart';
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

cat > "$BASE_DIR/primary_input_widget.dart" <<EOF
import '../utils/basic_import.dart';

class PrimaryInputFieldWidget extends StatefulWidget {
  final String hintText;
  final String? label;
  final bool isPassword;
  final bool isEmail;
  final String? optionalText;
  final TextInputType? keyBoardType;
  final String? Function(String?)? validatorLogic;
  final bool readOnly;
  final Color? fillColor;
  final Function(String)? onChange;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final int maxLines;
  final TextEditingController? confirmWith;
  final bool requiredField;
  final bool showBorder;

  const PrimaryInputFieldWidget({
    super.key,
    this.label,
    this.isPassword = false,
    this.isEmail = false,
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.maxLines = 1,
    this.keyBoardType,
    this.validatorLogic,
    this.readOnly = false,
    this.optionalText,
    this.fillColor,
    required this.hintText,
    this.confirmWith,
    this.requiredField = true,
    this.showBorder = false,
    this.onChange, // default true
  });

  @override
  State<PrimaryInputFieldWidget> createState() =>
      _PrimaryInputFieldWidgetState();
}

class _PrimaryInputFieldWidgetState extends State<PrimaryInputFieldWidget> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {});
    });

    // Live confirm password check
    widget.confirmWith?.addListener(() {
      if (widget.controller.text.isNotEmpty) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    // ✅ Skip validation if requiredField is false
    if (!widget.requiredField) return null;

    if (value == null || value.trim().isEmpty) {
      return Strings.pleaseFillOutTheField;
    }
    if (widget.isEmail) {
      final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email";
    }

    // Only enforce min length on password field, not confirm
    if (widget.isPassword && widget.confirmWith == null) {
      if (value.length < 6) return "Password must be at least 6 characters";
    }

    // ✅ Live confirm password validation
    if (widget.confirmWith != null && value != widget.confirmWith!.text) {
      return "Passwords do not match";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextWidget(
                    widget.label!,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                    fontSize: Dimensions.titleMedium * 0.9,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.blackColor,
                  ),
                ),
                if (widget.optionalText?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.only(left: Dimensions.widthSize * 0.5),
                    child: TextWidget(
                      widget.optionalText!,
                      fontSize: Dimensions.titleMedium * 0.9,
                      style: CustomStyle.labelSmall.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      color: CustomColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        TextFormField(
          onChanged: widget.onChange,
          style: TextStyle(
            color: widget.readOnly == true ? Colors.grey : Colors.black,
          ),
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.isPassword ? _obscureText : false,
          maxLines: widget.maxLines,
          cursorColor: CustomColors.primary,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validatorLogic ?? _validate,
          textInputAction: widget.nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: CustomStyle.bodyMedium.copyWith(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
              fontSize: Dimensions.titleMedium * 0.95,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _focusNode.hasFocus
                          ? CustomColors.primary
                          : CustomColors.disableColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: widget.fillColor != null,
            fillColor:
                widget.fillColor ??
                // Theme.of(context).colorScheme.surface,
                CustomColors.whiteColor.withAlpha(45),

            border: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.8,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: widget.readOnly == true
                  ? BorderSide(color: CustomColors.disableColor, width: 1.4)
                  : BorderSide(color: CustomColors.primary, width: 1.4),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: CustomColors.primary.withAlpha(45),
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.rejected, width: 1.4),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.rejected, width: 1.4),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
EOF

cat > "$BASE_DIR/time_picker_widget.dart" <<EOF
import '../utils/basic_import.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final String hint;
  final String? label;
  final TimeOfDay? initialTime;
  final Function(String) onTimeSelected; // String (HH:mm)

  const TimePickerWidget({
    super.key,
    this.hint = "Select Time",
    this.initialTime,
    required this.onTimeSelected,
    this.label,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),

      // initialEntryMode: TimePickerEntryMode.input, // <-- ছোট ডিজাইন
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CustomColors.primary,
              // ঘণ্টা/মিনিট সিলেক্ট করলে হাইলাইট রঙ
              onPrimary: Colors.white,
              surface: CustomColors.whiteColor,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: CustomColors.primary, // AM/PM background
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return CustomColors.primary; // আনসিলেক্টেড
              }),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: CustomColors.primary),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.primary,
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: CustomColors.whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      // Convert to string HH:mm
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final formatted = DateFormat('HH:mm').format(dt);

      widget.onTimeSelected(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsetsGeometry.only(
            bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
          ),
          widget.label ?? "Select Time",
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w500,
          color: CustomColors.blackColor.withAlpha(888),
        ),
        InkWell(
          onTap: () => _pickTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: Dimensions.defaultHorizontalSize.edgeHorizontal * 0.5,
            height: Dimensions.inputBoxHeight * 0.7,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedTime == null
                    ? CustomColors.disableColor
                    : CustomColors.primary,
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  _selectedTime == null
                      ? widget.hint
                      : _selectedTime!.format(context), // local formatted

                  fontSize: Dimensions.titleSmall,
                  color: _selectedTime == null
                      ? CustomColors.disableColor
                      : Colors.black,
                ),
                Icon(
                  Icons.access_time,
                  color: _selectedTime == null
                      ? CustomColors.disableColor
                      : CustomColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
EOF


cat > "$BASE_DIR/timer_widget.dart" <<EOF
import 'dart:async';
import '../utils/basic_import.dart';
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key, required this.onResendCode});

  final VoidCallback onResendCode;

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int totalTimeInSeconds;
  Timer? _timer;
  bool showResend = false;

  @override
  void initState() {
    super.initState();
    totalTimeInSeconds = _parseTime('00:30');
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalTimeInSeconds > 0) {
        setState(() {
          totalTimeInSeconds--;
        });
      } else {
        setState(() {
          showResend = true; // Show "Resend" when the timer ends
        });
        timer.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      totalTimeInSeconds = _parseTime('00:30');
      showResend = false; // Hide "Resend" and show the timer again
    });
    startTimer();
  }

  // Parse the "mm:ss" format into total seconds
  int _parseTime(String time) {
    final parts = time.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    return minutes * 60 + seconds;
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.5),
      child: Row(
        mainAxisAlignment: mainCenter,
        children: [
          TextWidget(
            'Didn’t get a code? ',
            fontWeight: FontWeight.w400,
            fontSize: Dimensions.titleSmall,
          ),
          Space.width.v5,
          TextWidget(
            showResend ? 'Resend Code' : formatTime(totalTimeInSeconds),
            color: CustomColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: Dimensions.titleSmall,
            onTap: () {
              if (showResend) {
                widget.onResendCode();
                resetTimer();
              }
            },
          ),
        ],
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/custom_snackbar.dart" <<EOF
import '../utils/basic_import.dart';
class CustomSnackBar {
  static void success({
    required String title,
    required String message,
    void Function(GetSnackBar)? onTap,
  }) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.rawSnackbar(
        backgroundColor: CustomColors.primary,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.7,
          vertical: Dimensions.verticalSize * 0.3,
        ),
        padding: EdgeInsets.all(Dimensions.paddingSize * 0.45),
        borderRadius: Dimensions.radius * 1.5,
        messageText: CustomSnackbarContent(
          title: title,
          message: message,
          type: 'success',
        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 7,
            color: CustomColors.blackColor.withOpacity(0.05),
          ),
        ],
      );
    });
  }

  static void error(String message) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.rawSnackbar(
        backgroundColor: CustomColors.secondary,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.7,
          vertical: Dimensions.verticalSize * 0.3,
        ),
        padding: EdgeInsets.all(Dimensions.paddingSize * 0.45),
        borderRadius: Dimensions.radius * 1.5,
        messageText: CustomSnackbarContent(
          title: Strings.error,
          message: message,
          type: 'error',
        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 7,
            color: CustomColors.blackColor.withOpacity(0.05),
          ),
        ],
      );
    });
  }
}

// snackbar widget
class CustomSnackbarContent extends StatelessWidget {
  final String title, message, type;

  const CustomSnackbarContent({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(
        //   type == 'success' ? Assets.icons.success : Assets.icons.reject,
        //   height: Dimensions.heightSize * 4.5,
        // ),
        Space.width.v10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                title,
                color: CustomColors.whiteColor,
                fontSize: Dimensions.titleSmall * 0.8,
                fontWeight: FontWeight.w400,
              ),
              Space.height.v5,
              TextWidget(
                message
                    .replaceAll(RegExp(r'\['), '')
                    .replaceAll(RegExp(r'\]'), ''),
                color: CustomColors.whiteColor,
                fontSize: Dimensions.labelSmall * 0.9,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
EOF

cat > "$BASE_DIR/custom_drop_down_widget.dart" <<EOF
import '../utils/basic_import.dart';
class CustomDropDownWidget extends StatefulWidget {
  final String hint;
  final String? label;
  final List<String> items;
  final String? initialValue;
  final Function(String) onChanged;

  const CustomDropDownWidget({
    super.key,
    this.hint = "Select Option",
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.label,
  });

  @override
  State<CustomDropDownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<CustomDropDownWidget> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsetsGeometry.only(
            bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
          ),
          widget.label ?? "Select option",
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w500,
          color: CustomColors.blackColor,
        ),
        Container(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal * 0.5,
          height: Dimensions.inputBoxHeight * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedValue == null
                  ? CustomColors.disableColor
                  : CustomColors.primary,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              dropdownColor: CustomColors.whiteColor,
              iconEnabledColor: _selectedValue == null
                  ? CustomColors.disableColor
                  : CustomColors.primary,
              value: _selectedValue,
              isExpanded: true,
              hint: TextWidget(
                widget.hint,
                color: Colors.grey,
                fontSize: width * 0.04,
              ),
              items: widget.items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: TextWidget(item, fontSize: Dimensions.titleSmall),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedValue = value);
                widget.onChanged(value!);
              },
            ),
          ),
        ),
      ],
    );
  }
}
EOF


cat > "$BASE_DIR/bottom_sheet_dialog_widget.dart" <<EOF
import '../utils/basic_import.dart';
class BottomSheetDialogWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? buttonTex;
  final String? firstButtonTex;
  final RxBool isLoading;
  final void Function() action;
  final bool? isInputField;
  final TextEditingController? inputController;

  const BottomSheetDialogWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.buttonTex,
    this.firstButtonTex,
    required this.isLoading,
    required this.action,
    this.isInputField = false,
    this.inputController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius * 1.5),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: Dimensions.widthSize * 4.2,
              height: Dimensions.heightSize * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                color: Colors.black,
              ),
            ),
          ),
          Space.height.v20,
          TextWidget(
            title,
            fontWeight: FontWeight.bold,
            fontSize: Dimensions.titleMedium * 1.1,
            padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.15),
          ),
          TextWidget(subTitle, fontSize: Dimensions.titleSmall),
          Space.height.betweenInputBox,
          if (isInputField == true) ...[
            PrimaryInputFieldWidget(
              controller: inputController ?? TextEditingController(),
              hintText: 'Enter Account Password',
            ),
            Space.height.betweenInputBox,
          ],
          if (isInputField == false) ...[
            PrimaryButtonWidget(
              title: firstButtonTex ?? 'Cancel',
              onPressed: () {
                Get.close(1);
              },
              buttonColor: Colors.grey.withOpacity(0.3),
              borderColor: Colors.white,
              buttonTextColor: Colors.black,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.verticalSize * 0.6,
            ),
            child: Obx(
              () => PrimaryButtonWidget(
                isLoading: isLoading.value,
                title: buttonTex ?? 'Yes',
                onPressed: action,
                buttonColor: Colors.red,
                borderColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/confirmation_widget.dart" <<EOF
import '../utils/basic_import.dart';
class ConfirmationWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ConfirmationWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: crossCenter,
        mainAxisAlignment: mainCenter,
        children: [
          SvgPicture.asset(iconPath),
          TextWidget(
            padding: EdgeInsetsGeometry.only(
              top: Dimensions.heightSize * 2,
              bottom: Dimensions.heightSize,
            ),
            title,
            fontWeight: titleStyle?.fontWeight ?? FontWeight.bold,
            fontSize: titleStyle?.fontSize ?? Dimensions.titleMedium * 1.2,
            color: titleStyle?.color,
          ),
          TextWidget(
            textAlign: TextAlign.center,
            subtitle,
            color: subtitleStyle?.color ?? CustomColors.grayShade,
            fontSize: subtitleStyle?.fontSize ?? Dimensions.titleSmall,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/custom_country_picker.dart" <<EOF
import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import '../utils/basic_import.dart';
class CustomCountryPicker extends StatelessWidget {
  final RxString selectedCountry;

  const CustomCountryPicker({super.key, required this.selectedCountry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        showCountryPicker(
          context: context,
          showSearch: false,
          useSafeArea: true,
          countryListTheme: CountryListThemeData(
            borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            backgroundColor: CustomColors.background,
            bottomSheetHeight: MediaQuery.of(context).size.height * 0.5,
            textStyle: TextStyle(color: CustomColors.whiteColor),
          ),
          onSelect: (Country country) {
            selectedCountry.value = country.name;
            log(selectedCountry.value);          },
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: CustomColors.secondary.withAlpha(95),
          borderRadius: BorderRadiusGeometry.circular(Dimensions.radius * 0.95),
          border: Border.all(color: CustomColors.secondary),
        ),
        width: double.infinity,
        height: Dimensions.inputBoxHeight * 0.8,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: Dimensions.widthSize * 1.2,
          ),
          child: Row(
            mainAxisAlignment: mainSpaceBet,
            children: [
              Obx(
                () => TextWidget(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimensions.bodyMedium,
                  selectedCountry.value,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/date_picker_widget.dart" <<EOF
import '../utils/basic_import.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final String hint;
  final String? label;
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    super.key,
    this.hint = "Select Date",
    this.initialDate,
    required this.onDateSelected,
    this.label,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _selectedDate;
  final DateFormat _formatter = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CustomColors.primary,
              onPrimary: Colors.white,
              surface: CustomColors.whiteColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.primary, // Button text color
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: CustomColors.whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsetsGeometry.only(
            bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
          ),
          widget.label ?? "Select Date",
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w500,
          color: CustomColors.blackColor.withAlpha(888),
        ),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          child: Container(
            padding: Dimensions.defaultHorizontalSize.edgeHorizontal * 0.5,
            height: Dimensions.inputBoxHeight * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: _selectedDate == null ?CustomColors.disableColor : CustomColors.primary, width: 1.4),
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextWidget(
                    _selectedDate == null
                        ? widget.hint
                        : _formatter.format(_selectedDate!),

                    fontSize: Dimensions.titleSmall,
                    color: _selectedDate == null
                        ? CustomColors.disableColor
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.calendar_today, color:_selectedDate == null ?CustomColors.disableColor : CustomColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
EOF
cat > "$BASE_DIR/divider_widget.dart" <<EOF
import '../utils/basic_import.dart';
class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Divider(
        color: CustomColors.disableColor.withOpacity(.4),
        thickness: 0.8,
      ),
    );
  }
}


class DividerWidgetTwo extends StatelessWidget {
  final double thickness;
  final Color color;

  const DividerWidgetTwo({
    super.key,
    this.thickness = 1,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: thickness,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/empty_data_widget.dart" <<EOF
import '../utils/basic_import.dart';
class EmptyDataWidget extends StatelessWidget {
  final String? massage;

  const EmptyDataWidget({super.key, this.massage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SvgPicture.asset(Assets.icons.empty),
            Space.height.v5,
            TextWidget(
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
              massage ?? Strings.noDataFound,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/expandable_text_widget.dart" <<EOF
import '../utils/basic_import.dart';
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int maxLines;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.maxLines = 6,
    this.fontSize = 14,
    this.color,
    this.fontWeight,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;
  bool showSeeMore = false;
  late String firstHalf;
  late String secondHalf;

  @override
  void initState() {
    super.initState();
    // Estimate if text exceeds limit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight ?? FontWeight.normal,
          ),
        ),
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: Get.width - Dimensions.defaultHorizontalSize * 2);

      if (textPainter.didExceedMaxLines) {
        setState(() => showSeeMore = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showSeeMore
          ? () {
              setState(() => isExpanded = !isExpanded);
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            widget.text,
            maxLines: isExpanded ? null : widget.maxLines,
            fontSize: widget.fontSize,
            color: widget.color ?? Colors.grey,
            fontWeight: widget.fontWeight,
            textOverflow: isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          if (showSeeMore)
            Padding(
              padding: EdgeInsets.only(top: Dimensions.heightSize * 0.4),
              child: TextWidget(
                isExpanded ? "See less" : "See more...",
                fontSize: widget.fontSize * 0.95,
                color: CustomColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
EOF

cat > "$BASE_DIR/loading_widget.dart" <<EOF
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/basic_import.dart';
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        color: color ?? CustomColors.primary,
        size: Dimensions.verticalSize * 1.5,
      ),
    );
  }
}

EOF


cat > "$BASE_DIR/otp_input_field.dart" <<EOF
import 'package:pin_code_fields/pin_code_fields.dart';
import '../utils/basic_import.dart';
class OtpInputField extends StatelessWidget {
  const OtpInputField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      length: 6,
      obscureText: true,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        selectedFillColor: CustomColors.secondary,
        inactiveFillColor: CustomColors.background,
        inactiveColor: CustomColors.secondary,
        selectedColor: CustomColors.primary,
        activeColor: CustomColors.primary,
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
        fieldHeight: 40.h,
        fieldWidth: 40.w,
        activeFillColor: CustomColors.secondary,
      ),
      animationDuration: Duration(milliseconds: 300),
      enableActiveFill: true,
      controller: controller,
      onCompleted: (v) {
        print("Completed");
      },

      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        return true;
      },
      appContext: context,
    );
  }
}
EOF
cat > "$BASE_DIR/profile_avater_widget.dart" <<EOF
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadify/shadify.dart';

import '../themes/token.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile; // ✅ New optional file
  final double size;

  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.size = 48,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageFile != null) {
      // ✅ Show local file image
      imageWidget = Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // ✅ Show network image
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size.w,
          height: size.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
        ).withShadifyLoading(
          loading: true,
          borderRadius: BorderRadius.circular(100.r),
        ),
        errorWidget: (context, url, error) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 20.h,
          ),
        ),
      );
    } else {
      // ✅ Default placeholder if nothing provided
      imageWidget = Container(
        width: size.w,
        height: size.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20.h,
        ),
      );
    }

    return Container(
      width: size.w,
      height: size.h,
      padding: hasBorder ? EdgeInsets.all(borderWidth) : EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(
          color: borderColor ?? CustomColors.primary,
          width: borderWidth,
        )
            : null,
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}
EOF
cat > "$BASE_DIR/custom_toggle_widget.dart" <<EOF
import '../utils/basic_import.dart';

//            // With 3 options
//             CustomToggleWidget(
//               options: ['Daily', 'Weekly', 'Monthly'],
//               initialIndex: 1,
//               onChanged: (index) {
//                 print('Selected index: $index');
//               },
//             ),
//             // Fully customized
//             CustomToggleWidget(
//               options: ['Option 1', 'Option 2', 'Option 3'],
//               height: 60.h,
//               margin: EdgeInsets.symmetric(horizontal: 20.w),
//               selectedColor: Colors.blue,
//               unselectedColor: Colors.grey.shade100,
//               borderColor: Colors.blue,
//               selectedTextColor: Colors.white,
//               unselectedTextColor: Colors.black,
//               borderWidth: 2.0,
//               borderRadius: 15,
//               initialIndex: 0,
//               onChanged: (index) {
//                 // Handle selection
//               },
//             ),

//            CustomToggleWidget(
//               options: ['English', 'Greek'],
//               initialIndex: AppStorage.languageCode == 'en' ? 0 : 1,
//               onChanged: (index) async {
//                 if (index == 0) {
//                   await AppStorage.saveLanguage('en');
//                   Get.updateLocale(Locale('en', 'US'));
//                 } else {
//                   await AppStorage.saveLanguage('gr');
//                   Get.updateLocale(Locale('gr', 'GK'));
//                 }
//               },
//             ),

class CustomToggleWidget extends StatefulWidget {
  final List<String> options;
  final int initialIndex;
  final Function(int)? onChanged;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double? borderWidth;
  final double? borderRadius;

  const CustomToggleWidget({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.onChanged,
    this.height,
    this.margin,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  State<CustomToggleWidget> createState() => _CustomToggleWidgetState();
}

class _CustomToggleWidgetState extends State<CustomToggleWidget> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 50.h;
    final margin =
        widget.margin ?? (Dimensions.defaultHorizontalSize.edgeHorizontal * 5);
    final selectedColor = widget.selectedColor ?? CustomColors.primary;
    final unselectedColor = widget.unselectedColor ?? Colors.transparent;
    final borderColor = widget.borderColor ?? CustomColors.primary;
    final selectedTextColor =
        widget.selectedTextColor ?? CustomColors.whiteColor;
    final unselectedTextColor =
        widget.unselectedTextColor ?? CustomColors.primary;
    final borderWidth = widget.borderWidth ?? 1.5;
    final borderRadius = widget.borderRadius ?? (Dimensions.radius * 2);

    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: CustomColors.whiteColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: List.generate(
          widget.options.length,
          (index) => Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Container(width: borderWidth, color: borderColor),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.onChanged?.call(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? selectedColor
                            : unselectedColor,
                        borderRadius: _getBorderRadius(
                          index,
                          borderRadius,
                          borderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextWidget(
                        widget.options[index],
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                        color: selectedIndex == index
                            ? selectedTextColor
                            : unselectedTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius? _getBorderRadius(int index, double radius, double borderWidth) {
    final adjustedRadius = radius - borderWidth;

    if (widget.options.length == 1) {
      return BorderRadius.circular(adjustedRadius);
    }
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(adjustedRadius),
        bottomLeft: Radius.circular(adjustedRadius),
      );
    } else if (index == widget.options.length - 1) {
      return BorderRadius.only(
        topRight: Radius.circular(adjustedRadius),
        bottomRight: Radius.circular(adjustedRadius),
      );
    }
    return null;
  }
}
EOF

cat > "$BASE_DIR/multi_selection_dropdown.dart" <<EOF
import '../utils/basic_import.dart';

class MultiSelectDropDownWidget extends StatefulWidget {
  final String hint;
  final String? label;
  final List<String> items;
  final List<String>? initialValues;
  final Function(List<String>) onChanged;

  const MultiSelectDropDownWidget({
    super.key,
    this.hint = "Select Options",
    required this.items,
    this.initialValues,
    required this.onChanged,
    this.label,
  });

  @override
  State<MultiSelectDropDownWidget> createState() =>
      _MultiSelectDropDownWidgetState();
}

class _MultiSelectDropDownWidgetState extends State<MultiSelectDropDownWidget> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialValues ?? [];
  }

  void _toggleValue(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
    widget.onChanged(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsetsGeometry.only(
            bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
          ),
          widget.label ?? "Select Category",
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w500,
          color: CustomColors.blackColor,
        ),

        if (_selectedValues.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedValues
                .map((item) => Chip(
              label: TextWidget(item,
                  fontSize: Dimensions.titleSmall,
                  color: CustomColors.blackColor),
              backgroundColor: CustomColors.whiteColor,
              shape: StadiumBorder(
                side: BorderSide(color: CustomColors.primary, width: 1),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _toggleValue(item),
            ))
                .toList(),
          ).marginOnly(bottom: 8),

        Container(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal * 0.5,
          height: Dimensions.inputBoxHeight * 0.7,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedValues.isEmpty
                  ? CustomColors.disableColor
                  : CustomColors.primary,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: CustomColors.whiteColor,
              iconEnabledColor: _selectedValues.isEmpty
                  ? CustomColors.disableColor
                  : CustomColors.primary,
              value: null, 
              isExpanded: true,
              hint: TextWidget(
                widget.hint,
                color: Colors.grey,
                fontSize: width * 0.04,
              ),
              items: widget.items
                  .map(
                    (item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedValues.contains(item),
                        activeColor: CustomColors.primary,
                        onChanged: (_) => _toggleValue(item),
                      ),
                      TextWidget(item,
                          fontSize: Dimensions.titleSmall,
                          color: CustomColors.blackColor),
                    ],
                  ),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) _toggleValue(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
EOF

cat > "$BASE_DIR/terms_and_policy.dart" <<EOF
import '../utils/basic_import.dart';

class TermsAndPolicyWidget extends StatelessWidget {
  final RxBool isChecked;
  final RxBool isError;
  final String mainText;
  final VoidCallback termsTap;
  final VoidCallback policyTap;

  const TermsAndPolicyWidget({
    super.key,
    required this.isChecked,
    required this.isError,
    required this.mainText,
    required this.termsTap,
    required this.policyTap,
  });

  void _toggle() {
    isChecked.value = !isChecked.value;
    if (isChecked.value) {
      isError.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const errorColor = Colors.red;
    const normalColor = Colors.grey;

    return InkWell(
      onTap: _toggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
                () => SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: isChecked.value,
                activeColor: primaryColor,

                side: BorderSide(
                  color: isError.value ? errorColor : CustomColors.disableColor,
                  width: 1.4.w,
                ),
                onChanged: (_) => _toggle(),
              ),
            ),
          ),
          Space.width.v10,
          Expanded(
            child: Obx(
                  () => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(
                  isError.value ? 10 : 0,
                  0,
                  0,
                ),
                child: Wrap(
                  children: [
                    _text(
                      "I have read and agree to $mainText's ",
                      color: isError.value ? errorColor : normalColor,
                    ),
                    _link(
                      "Terms & Conditions",
                      termsTap,
                      isError.value ? errorColor : primaryColor,
                    ),
                    _text(
                      " and ",
                      color: isError.value ? errorColor : normalColor,
                    ),
                    _link(
                      "Privacy Policy",
                      policyTap,
                      isError.value ? errorColor : primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _text(String text, {required Color color}) {
    return Text(text, style: TextStyle(fontSize: 14.sp, color: color));
  }

  Widget _link(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


EOF


cat > "$BASE_DIR/social_login_button.dart" <<EOF
import '../utils/basic_import.dart';

class SocialLoginButtonWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final double? radius;
  final VoidCallback onTap;

  const SocialLoginButtonWidget({
    super.key,
    required this.iconPath,
    required this.title,
    this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = radius ?? Dimensions.radius;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: Dimensions.heightSize * 0.2),
        height: Dimensions.buttonHeight * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(color: CustomColors.primary, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath),
            TextWidget(title, padding: Dimensions.widthSize.edgeLeft),
          ],
        ),
      ),
    );
  }
}

EOF

cat > "$BASE_DIR/webview_screen.dart" <<'EOF'
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/basic_import.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.title),
      body: Obx(
        () => Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (isLoading.value)
              Center(
                child: CircularProgressIndicator(color: CustomColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
EOF




cat > "lib/core/helpers/network_manager.dart" <<EOF
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  static Future<bool> hasConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Stream<bool> connectionStream() async* {
    await for (var results in Connectivity().onConnectivityChanged) {
      if (results.contains(ConnectivityResult.none)) {
        yield false;
      } else {
        yield true;
      }
    }
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
