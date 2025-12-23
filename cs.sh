#!/usr/bin/env bash
set -e  


# 🌈 Terminal Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BASE_DIR="lib"
ASSET_DIR="assets"

echo -e "${CYAN}📁 Creating Your Custom Structure ...${NC}"

mkdir -p "$ASSET_DIR"/{icons,logo,dummy}


# --- Bindings folder
mkdir -p "$BASE_DIR/bind"

# --- Core folders
mkdir -p "$BASE_DIR/core"/{api,helpers,languages,themes,utils}
mkdir -p "$BASE_DIR/core/api"/{end_point,services}

# Core files
touch "$BASE_DIR/core/api/services"/{api_request.dart,auth_services.dart}
touch "$BASE_DIR/core/api/end_point"/api_end_points.dart
touch "$BASE_DIR/core/helpers"/helpers.dart
touch "$BASE_DIR/core/utils"/{basic_import.dart,app_storage.dart,app_storage_model.dart,custom_style.dart,dimensions.dart,extensions.dart,layout.dart,space.dart}
touch "$BASE_DIR/core/themes"/{custom_colors.dart,model.dart,themes.dart,token.dart}
touch "$BASE_DIR/core/languages"/{localization.dart,strings.dart}

# --- Resources
mkdir -p "$BASE_DIR/res"
touch "$BASE_DIR/res/assets.dart"

# --- Routes
mkdir -p "$BASE_DIR/routes"
touch "$BASE_DIR/routes"/{pages.dart,routes.dart}
mkdir -p "$BASE_DIR/views"

# --- Main entry files
touch "$BASE_DIR"/{main.dart,initial.dart}





















# ---------------- main.dart
echo -e "${YELLOW}📄 Writing main.dart ...${NC}"
cat <<EOF > "$BASE_DIR/main.dart"
import 'core/api/helpers/network_manager.dart';
import 'core/utils/basic_import.dart';
import 'initial.dart';
import 'routes/routes.dart';
import 'views/splash/controller/splash_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Initial.init();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: CustomColors.backgroundDark),
  );

  final hasInternet = await NetworkManager.hasConnection();
  bool? lastStatus = hasInternet;
  NetworkManager.connectionStream().listen((isConnected) {
    if (lastStatus != null && lastStatus != isConnected) {
      if (!isConnected) {
       Get.toNamed(Routes.offlineScreen);
      } else {
        if (Get.currentRoute == Routes.offlineScreen) {
        Get.offAllNamed(Routes.splashScreen);
        }
        CustomSnackBar.success(
          title: Strings.connectionRestored,
          message: Strings.youAreBackOnline,
        );
      }
    }
    lastStatus = isConnected;
  });

  runApp(MyApp(hasInternet: hasInternet));
}

class MyApp extends StatelessWidget {
  final bool hasInternet;

  const MyApp({super.key, required this.hasInternet});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 915),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: hasInternet ? Routes.splashScreen : Routes.offlineScreen,
        title: Strings.appName,
        theme: Themes.light,
        darkTheme: Themes.dark,
        getPages: Routes.list,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 400),
        themeMode: ThemeMode.light,
        initialBinding: BindingsBuilder(() {
          Get.lazyPut(() => SplashController());
        }),

        builder: (context, widget) {
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (ctx) {
                  return Directionality(
                    textDirection: Get.locale?.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: widget!,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
EOF

# ---------------- initial.dart
cat <<EOF > "$BASE_DIR/initial.dart"
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';

class Initial {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    await ScreenUtil.ensureScreenSize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
EOF

echo -e "${GREEN}✅ Flutter project structure created successfully!${NC}"
