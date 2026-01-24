#!/usr/bin/env bash
set -euo pipefail

echo "📁 Creating YOUR CODE API METHOD..."

BASE_DIR="lib/core/api/services"
ENDPOINT_DIR="lib/core/api/end_point"

# ✅ Ensure the directories exist
mkdir -p "$BASE_DIR"
mkdir -p "$ENDPOINT_DIR"

# ✅ Write the ApiEndPoints class
cat > "$ENDPOINT_DIR/api_end_points.dart" <<'EOF'
class ApiEndPoints {
  static const String baseUrl = 'https://api.yourapp.com/api/v1';

  // AUTH ENDPOINTS
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  //  USER ENDPOINTS
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String deleteAccount = '/user/delete';

  //  PRODUCT ENDPOINTS
  static const String products = '/products';
  static const String productDetails = '/products';
  static const String deleteProduct = '/products';

  // UPLOAD ENDPOINTS
  static const String uploadImage = '/upload/image';
  static const String uploadGallery = '/upload/gallery';
  static const String uploadDocument = '/upload/document';

  // FAVORITE ENDPOINTS
  static const String toggleFavorite = '/favorites/toggle';
  static const String getFavorites = '/favorites';

  // SEARCH ENDPOINTS
  static const String search = '/search';
}
EOF

# ✅ Write the ApiRequest class
cat > "$BASE_DIR/api_request.dart" <<'EOF'
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../utils/app_storage.dart';
import '../../utils/basic_import.dart';
import '../end_point/api_end_points.dart';

class ApiRequest {
  
  /// ✅ Header Generator
  static Future<Map<String, String>> _bearerHeaderInfo([String? token]) async {
    final authToken = token ?? AppStorage.token;
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
      if (authToken.isNotEmpty)
        HttpHeaders.authorizationHeader: "Bearer $authToken",
    };
  }
  static void printBody(Map<String, dynamic> body) {
    body.forEach((key, value) {
      log("🔹 '$key': '$value'");
    });
    log('╚════════════════════════════════════════════════════════════════════════════════════════════');
  }
  static void printUrl(String url) {
    log('╔════════════════════════════════════════════════════════════════════════════════════════════');
    log("📍 'End Point': '$url'");
  }

  /// =========================================================== ✅ POST REQUEST =========================================================== ///
  static Future<R> post<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
    
  }) async {
    try {
      isLoading.value = true;
      log('|📤|---------[ 📦 POST REQUEST STARTED ]---------|📤|');

      final uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint').replace(queryParameters: queryParams);
      printUrl(uri.toString());
      printBody(body);

      final response = await http.post(uri, headers: await _bearerHeaderInfo(),
          body: jsonEncode(body)).timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ POST REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage = json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) CustomSnackBar.success(title: Strings.success, message: successMessage);
        if (onSuccess != null) onSuccess(result);
        return result;

      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }

    } catch (e) {
      log('🐞🐞🐞 ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ GET REQUEST =========================================================== ///
  static Future<R> get<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    String? id,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    bool showResponse = false,
    Function(R result)? onSuccess,
    
  }) async {
    try {
      isLoading.value = true;
      log('|📥|---------[ 🌐 GET REQUEST STARTED ]---------|📥|');

      String fullUrl = '${ApiEndPoints.baseUrl}$endPoint';
      if (id != null && id.isNotEmpty) {fullUrl += '/$id';}
      final uri = Uri.parse(fullUrl).replace(queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())));
      printUrl(uri.toString());
      
      final response = await http.get(uri, headers: await _bearerHeaderInfo()).timeout(const Duration(seconds: 120));
      if (showResponse) {
        try {
          final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
          log('|📤|---------[ RESPONSE BODY ]---------|📤|');
          log(prettyJson);
          log('|📤|---------------------------------|📤|');
        } catch (_) {
          log('|📤| RESPONSE (raw) |📤|: ${response.body}');
        }
      }
      
      log('|✅|---------[ ✅ GET REQUEST COMPLETED ]---------|✅|');
      log('╚════════════════════════════════════════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);
        
        final successMessage = json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {CustomSnackBar.success(title: Strings.success, message: successMessage);}
        if (onSuccess != null) onSuccess(result);
        return result;
        
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞🐞🐞 ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  
  
  
  
  // others
  
  
  
  
  
  
  
  
  
  
  
  /// =========================================================== ✅ PATCH REQUEST =========================================================== ///
  static Future<R> patch<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      log('|📤|---------[ 📦 PATCH REQUEST STARTED ]---------|📤|');

      // ✅ Build URL with queryParams
      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$endPoint',
      ).replace(queryParameters: queryParams);

      printUrl(uri.toString());
      printBody(body);

      final response = await http
          .patch(
            uri,
            headers: await _bearerHeaderInfo(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ PATCH REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ PUT REQUEST =========================================================== ///
  static Future<R> put<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      log('|📤|---------[ 📦 PUT REQUEST STARTED ]---------|📤|');

      // ✅ Build URL with queryParams
      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$endPoint',
      ).replace(queryParameters: queryParams);

      printUrl(uri.toString());
      printBody(body);

      final response = await http
          .put(uri, headers: await _bearerHeaderInfo(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ PUT REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ DELETE REQUEST =========================================================== ///
  static Future<R> delete<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    String? id, // ✅ New optional parameter
    required RxBool isLoading,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      log('|📤|---------[ 📦 DELETE REQUEST STARTED ]---------|📤|');

      // ✅ Append id to endpoint if provided
      final fullEndPoint = id != null ? '$endPoint/$id' : endPoint;

      // ✅ Build URL with queryParams
      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$fullEndPoint',
      ).replace(queryParameters: queryParams);

      printUrl(uri.toString());
      if (body != null) printBody(body);

      final response = await http
          .delete(
            uri,
            headers: await _bearerHeaderInfo(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 120));

      log('|✅|---------[ ✅ DELETE REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final Map<String, dynamic> json = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ======================================================== ✅ Multipart POST Method ========================================================= ///
  static Future<R> multiMultipartRequest<R>({
    required String endPoint,
    required RxBool isLoading,
    required String reqType,
    required Map<String, dynamic> body,
    required Map<String, File?> files,
    Map<String, List<File>>? filesList,
    RxList<File>? selectedImages,
    List<String>? sizes, 
    String? singleQueryParam,
    required R Function(Map<String, dynamic>) fromJson,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
    String? token,
    
  }) async {
    try {
      isLoading.value = true;
      final headers = await _bearerHeaderInfo(token);

      // Build URL
      String fullUrl = '${ApiEndPoints.baseUrl}$endPoint';
      if (singleQueryParam != null && singleQueryParam.isNotEmpty) {
        if (!singleQueryParam.startsWith('/')) fullUrl += '/';
        fullUrl += singleQueryParam;
      }
      final uri = Uri.parse(fullUrl);
      log('📤 MULTIPART REQUEST STARTED');
      log('🔗 Method  : $reqType');
      printBody(body);
      printUrl(uri.toString());

      final request = http.MultipartRequest(reqType.toUpperCase(), uri);
      request.headers.addAll(headers);

      // Add body fields safely
      body.forEach((key, value) {
        if (value is List || value is Map) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value?.toString() ?? '';
        }
      });

      if (sizes != null && sizes.isNotEmpty) {
        request.fields['sizes'] = jsonEncode(sizes);
        log('📏 SIZES: $sizes');
      }

      // Add single files safely
      for (var entry in files.entries) {
        final file = entry.value;
        if (file == null) continue;

        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        log('🧪 MIME TYPE for ${entry.key}: $mimeType');

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      if (selectedImages != null && selectedImages.isNotEmpty) {
        for (var file in selectedImages) {
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          log('🖼️ Adding image: ${file.path} | MIME: $mimeType');

          request.files.add(await http.MultipartFile.fromPath('images',file.path,contentType: MediaType.parse(mimeType),),
          );
        }
      }

      // Rest of your code...
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      final response = await http.Response.fromStream(streamedResponse);

      log('📬 RESPONSE STATUS: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final result = fromJson(json);

        if (showSuccessSnackBar) {
          final successMessage = json['message'] ?? 'Request completed successfully';
          CustomSnackBar.success(title: 'Success', message: successMessage);
        }

        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        log('❌ MULTIPART ERROR: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('🐞 MULTIPART UNHANDLED ERROR: $e');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  

  /// Reusable favorite toggle method for any project
  /// Usage Example:
  
  /// await ApiRequest.toggleFavorite(
  ///   itemId: product.id,
  ///   isFavorite: product.isFavourite,
  ///   endPoint: ApiEndPoints.favourites,
  ///   itemKey: 'product',
  ///   showSuccessSnackBar: true,

  static Future<bool> toggleFavorite({
    required dynamic itemId,
    required RxBool isFavorite,
    required String endPoint,
    String itemKey = 'product',
    VoidCallback? onSuccess,
    Function(String message)? onError,
    bool showSuccessSnackBar = false,
    String? customSuccessMessage,
    Map<String, dynamic>? customBody,
    Map<String, dynamic>? queryParams,
  }) async {
    final oldValue = isFavorite.value;

    try {
      isFavorite.value = !oldValue;
      
      final uri = Uri.parse('${ApiEndPoints.baseUrl}$endPoint').replace(queryParameters: queryParams);
      final body = customBody ?? {itemKey: itemId};
      
      final response = await http.post(uri, headers: await _bearerHeaderInfo(), body: jsonEncode(body)).timeout(const Duration(seconds: 120));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final isSuccess = json['success'] ?? true;

        if (isSuccess) {onSuccess?.call();
          if (showSuccessSnackBar) {
            final successMessage = customSuccessMessage ?? json['message'] ??
                (isFavorite.value ? 'Added to favorites' : 'Removed from favorites');
            CustomSnackBar.success(title: Strings.success, message: successMessage);
          }
          return true;
          
        } else {
          isFavorite.value = oldValue;
          final errorMessage = json['message'] ?? 'Favorite update failed';
          log('❌ Favorite Error: $errorMessage');
          onError?.call(errorMessage);
          return false;
        }
      } else {
        isFavorite.value = oldValue;
        final error = jsonDecode(response.body);
        final errorMessage = (error);
        log('❌  Error: $errorMessage');
        onError?.call(errorMessage);
        CustomSnackBar.error(errorMessage);
        return false;
      }
    } catch (e) {
      isFavorite.value = oldValue;
      final errorMessage = 'Failed to update favorite';
      log('🐞🐞🐞 ERROR: ${e.toString()}');
      onError?.call(errorMessage);
      return false;
    }
  }
  
}

EOF



echo "╔════════════════════════════════════════════════════════════╗"
echo "         🚀✨ Successfully Created Api Method 🎉              "
echo "╚════════════════════════════════════════════════════════════╝"
