#!/bin/bash

# 🔠 Convert snake_case to PascalCase
capitalize() {
  IFS='_' read -ra parts <<< "$1"
  result=""
  for part in "${parts[@]}"; do
    result+=$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}
  done
  echo "$result"
}

for viewName in "$@"; do
  capitalizedViewName=$(capitalize "$viewName")
  base_dir="lib/views/$viewName"
  echo "📦 Generating view: $viewName"

  mkdir -p "$base_dir/controller"
  mkdir -p "$base_dir/screen"
  mkdir -p "$base_dir/widget"
  mkdir -p "lib/bind"

  # 🎯 Controller File
  cat <<EOF > "$base_dir/controller/${viewName}_controller.dart"
import '../../../core/utils/basic_import.dart';
class ${capitalizedViewName}Controller extends GetxController {











}
EOF

  # 📱 Mobile Screen File
  cat <<EOF > "$base_dir/screen/${viewName}_screen_mobile.dart"
part of '${viewName}_screen.dart';

class ${capitalizedViewName}ScreenMobile extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}ScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "${capitalizedViewName}"),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          physics: BouncingScrollPhysics(),
          children: [

          
          ],
        ),
      ),
    );
  }
}
EOF

  # 🧩 Main Screen File
  cat <<EOF > "$base_dir/screen/${viewName}_screen.dart"
import '../../../core/utils/basic_import.dart';
import '../controller/${viewName}_controller.dart';

part '${viewName}_screen_mobile.dart';
EOF

  # 🔚 Append class definition to main screen
  cat <<EOF >> "$base_dir/screen/${viewName}_screen.dart"

class ${capitalizedViewName}Screen extends GetView<${capitalizedViewName}Controller> {
  const ${capitalizedViewName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: ${capitalizedViewName}ScreenMobile());
  }
}
EOF

  # 🔗 Binding File
  cat <<EOF > "lib/bind/${viewName}_binding.dart"
import 'package:get/get.dart';
import '../views/$viewName/controller/${viewName}_controller.dart';

class ${capitalizedViewName}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${capitalizedViewName}Controller>(() => ${capitalizedViewName}Controller());
  }
}
EOF

  # 🛤️ Add route constant to routes.dart
  route_file="lib/routes/routes.dart"
  route_name="${viewName}Screen"
  route_const="static const $route_name = '/$route_name';"


  screen_import_route="import '../views/$viewName/screen/${viewName}_screen.dart';"
binding_import_route="import '../bind/${viewName}_binding.dart';"
grep -qxF "$screen_import_route" "$route_file" || sed -i "1i $screen_import_route" "$route_file"
grep -qxF "$binding_import_route" "$route_file" || sed -i "1i $binding_import_route" "$route_file"


  grep -qxF "$route_const" "$route_file" || sed -i "/static var list = RoutePageList.list;/a $route_const" "$route_file"




  # 📥 Add GetPage to pages.dart
  page_file="lib/routes/pages.dart"
  screen_import="import '../views/$viewName/screen/${viewName}_screen.dart';"
  binding_import="import '../bind/${viewName}_binding.dart';"

  grep -qxF "$screen_import" "$page_file" || sed -i "/^import/a $screen_import" "$page_file"
  grep -qxF "$binding_import" "$page_file" || sed -i "/^import/a $binding_import" "$page_file"

  route_code="GetPage(\n    name: Routes.${viewName}Screen,\n    page: () => const ${capitalizedViewName}Screen(),\n    binding: ${capitalizedViewName}Binding(),\n  ),"
  sed -i "/\/\/Page Route List/a $route_code" "$page_file"



  # ✨ Fancy Success Log
  echo -e "╔════════════════════════════════════════════════════════════╗"
  echo -e "  🚀✨ Successfully Created Your View 🎉🧩📱🔗"
  echo -e "╚════════════════════════════════════════════════════════════╝"

done
