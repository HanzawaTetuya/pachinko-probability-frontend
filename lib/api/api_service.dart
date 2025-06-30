import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // HttpException を利用するためのインポート
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart';

const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8888/api/user',
);

class ApiService {
  // token取得用のメソッド
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ユーザー登録情報を送信
  Future<http.Response?> createAccount(
    String username,
    String email,
    String dateOfBirth, {
    String? referralCode,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final Map<String, dynamic> requestBody = {
      'username': username,
      'email': email,
      'date_of_birth': dateOfBirth,
    };

    if (referralCode != null && referralCode.isNotEmpty) {
      requestBody['referral_code'] = referralCode;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("【デバック-002】Error during registration: $e");
      }
      return null;
    }
  }

  Future<http.Response?> verifyCode(String email, String code) async {
    try {
      final url = Uri.parse('$baseUrl/verify-code');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      return response; // 必ず http.Response を返す
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-003] Error during verifyCode: $e');
      }
      return null; // エラー時には null を返す
    }
  }

// パスワードの追加登録
  Future<http.Response?> registerUser(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl/add-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-004] Error during registration: $e');
      }
      return null;
    }
  }

  // ログインメソッド
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        if (kDebugMode) {
          print('[デバッグ-005] Login failed: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-005] Error during login: $e');
      }
      return null;
    }
  }

  Future<http.Response?> verifyLoginCode(String userId, String code) async {
    final url = Uri.parse('$baseUrl/verify-login-code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        // レスポンスデータをデコード
        final responseData = jsonDecode(response.body);

        // アクセストークンを取得
        final accessToken = responseData['access_token'];

        // アクセストークンが存在する場合、SharedPreferencesに保存
        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          if (kDebugMode) {
            print('[デバッグ-006] Access token saved to SharedPreferences');
          }
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-006] Error during verification: $e');
      }
      return null;
    }
  }

// パスワードをお忘れの方（ログインページより）
  Future<Map<String, dynamic>?> forgotPasswordInLogin(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password-in-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '不明なエラーが発生しました'};
      }
    } catch (e) {
      return {'success': false, 'message': '通信エラーが発生しました'};
    }
  }

  Future<Map<String, dynamic>?> verifyResetPasswordCode(
      String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-password-code'), // ← ルート名注意
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '不明なエラーが発生しました'};
      }
    } catch (e) {
      return {'success': false, 'message': '通信エラーが発生しました'};
    }
  }

  Future<Map<String, dynamic>?> resetPasswordInLogin(
      String email, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password-in-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'パスワードの再設定に失敗しました'};
      }
    } catch (e) {
      return {'success': false, 'message': '通信エラーが発生しました'};
    }
  }

  // ログアウトメソッド
  Future<void> logoutUser() async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      print('ログアウトエラー: トークンが見つかりません');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        print('ログアウト成功');
      } else {
        print('ログアウト失敗: ${response.body}');
      }
    } catch (e) {
      print('ログアウト中にエラーが発生しました: $e');
    }
  }

  Future<void> debugPrintSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (String key in keys) {
      final value = prefs.get(key);
    }
  }

// ホーム画面処理
  Future<Map<String, dynamic>> homeData() async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/home-data');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));

        if (data['success'] == true) {
          return {
            'userInfo': Map<String, dynamic>.from(data['userInfo'] ?? {}),
            'usageData': Map<String, dynamic>.from(data['usageData'] ?? {}),
            'product': Map<String, dynamic>.from(data['product'] ?? {}),
            'newsData': List<dynamic>.from(data['newsData'] ?? []),
          };
        } else {
          throw 'サーバーエラー: ${data['message'] ?? '不明なエラー'}';
        }
      } else {
        throw 'HTTPエラー: ステータスコード ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-007] エラー: $e');
      }
      throw '使用履歴の取得中にエラーが発生しました: $e';
    }
  }

  // ユーザー情報取得
  Future<Map<String, dynamic>> getUserInfo() async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/user-info');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data ?? {}; // null を防ぐために空のマップを返す
    } else {
      throw 'ユーザー情報の取得に失敗しました';
    }
  }

  // ユーザーネームの更新
  Future<bool> editUserName(String newUserName) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-008] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/edit-username');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': newUserName}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print(
              '[デバッグ-008] Username updated successfully: ${responseData['username']}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print(
              '[デバッグ-008] Failed to update username: ${jsonDecode(response.body)}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-008] Error updating username: $e');
      }
      return false;
    }
  }

// メールアドレスの更新
  Future<bool> editEmail(String email) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-009] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/edit-email');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-009] ${responseBody['message'] ?? 'メールアドレス変更成功'}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-009] ${responseBody['message'] ?? 'エラーが発生しました'}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-009] 通信エラー: $e');
      }
      return false;
    }
  }

  // メールアドレス変更のコード認証
  Future<bool> verifyEmailCode(String code) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-010] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/verify-email-code');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-010] コードの認証に成功したのでメールアドレスを更新します。');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-010] コードの認証に失敗しました。');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-010] Error sending password: $e');
      }
      return false;
    }
  }

// パスワードの変更
  Future<bool> editPassword(String password) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-011] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/edit-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-011] 既存のパスワードの送信に成功しました。');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-011] 既存のパスワードの送信に失敗しました。');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-011] Error sending password: $e');
      }
      return false;
    }
  }

  Future<bool> verifyPasswordCode(String code) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-012] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/verify-password-code');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-012] 認証コードの送信に成功しました。');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-012] 認証コードの送信に失敗しました。');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-012] Error sending password: $e');
      }
      return false;
    }
  }

  Future<bool> updatePassword(
    String password,
    String password_confirmation,
  ) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-013] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/update-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'password': password,
          'password_confirmation': password_confirmation,
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-013] パスワードの送信に成功しました。');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-013] パスワードの送信に失敗しました。');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-013] Error sending password: $e');
      }
      return false;
    }
  }

// パスワードをお忘れの方
  Future<bool> forgotPasswordInMypage() async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-014] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/forgot-password-in-mypage');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-014] ✅ 認証コード送信成功: ${response.body}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-014] ❌ 認証コード送信失敗: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-014] 🚨 API通信エラー: $e');
      }
      return false;
    }
  }

//お問い合わせ処理
  Future<String?> sendInquiry(String subject, String message) async {
    final token = await getToken();
    if (token == null) return 'トークンがありません';

    final url = Uri.parse('$baseUrl/contact');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': subject,
          'message': message,
        }),
      );

      if (kDebugMode) {
        print('[デバッグ-015] 📦 ステータスコード: ${response.statusCode}');
        print('[デバッグ-015] 📦 レスポンスボディ: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return null; // 成功なのでエラーはなし
        } else {
          return '送信に失敗しました';
        }
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        final errors = errorData['errors'];

        if (errors['subject'] != null) {
          return errors['subject'][0];
        } else if (errors['message'] != null) {
          return errors['message'][0];
        } else {
          return '不明なエラーが発生しました';
        }
      } else {
        return 'サーバーエラーが発生しました（${response.statusCode}）';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-015] ❌ お問い合わせ送信エラー: $e');
      }
      return '通信エラーが発生しました';
    }
  }

// 商品管理エリア
// 商品情報一覧の取得
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (kDebugMode) {
        print('[デバッグ-016] 取得した商品データ: ${jsonData['data']}');
      }

      if (jsonData['success']) {
        return (jsonData['data'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      throw Exception('Failed to connect to API');
    }
  }

// お気に入り管理エリア
  Future<bool> isFavorite(int productId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-017] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/favorites/check');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_number': productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorite'];
      } else {
        if (kDebugMode) {
          print('[デバッグ-017] お気に入り確認に失敗しました: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-017] エラー: $e');
      }
      return false;
    }
  }

  Future<bool> addFavorite(int productId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-018] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/favorites');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_number': productId}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-018] お気に入りに追加しました');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-018] お気に入りの追加に失敗しました: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-018] エラー: $e');
      }
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-019] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/favorites');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_number': productId}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-019] お気に入りから削除しました');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-019] お気に入りの削除に失敗しました: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-019] エラー: $e');
      }
      return false;
    }
  }

  Future<List<dynamic>> getFavorites() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-020] トークンが見つかりません');
      }
      return [];
    }

    final url = Uri.parse('$baseUrl/favorites');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-020] お気に入りリストを取得しました');
        }
        return data['favorites'];
      } else {
        if (kDebugMode) {
          print('[デバッグ-020] お気に入りの取得に失敗しました: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-020] エラー: $e');
      }
      return [];
    }
  }

// カート機能
// カート内確認
  Future<bool> checkCart(int productId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-021] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/cart/check');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_number': productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorite'];
      } else {
        if (kDebugMode) {
          print('[デバッグ-021] カート内の情報が確認できませんでした。: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-021] エラー: $e');
      }
      return false;
    }
  }

// カートに追加
  Future<String> addToCart(int productId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-022] トークンが見つかりません');
      }
      return 'token_missing'; // トークンがない場合のステータス
    }

    final url = Uri.parse('$baseUrl/cart/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_number': productId}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-022] 商品のカート追加に成功しました。');
        }
        return 'added_to_cart'; // カート追加成功
      } else {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-022] カート追加エラー: ${data['message']}');
        }
        return data['status'] ?? 'unknown_error'; // サーバーからのステータスを返す
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-022] エラー: $e');
      }
      return 'error'; // その他のエラー
    }
  }

// カート内の情報収集する
  Future<List<dynamic>> getCarts() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-023] トークンが見つかりません');
      }
      return [];
    }

    final url = Uri.parse('$baseUrl/cart/list');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('[デバッグ-023] お気に入りリストを取得しました:');
          print('[デバッグ-023] カートの詳細:');
          for (var cart in data['carts']) {
            print(
                '[デバッグ-023] ID: ${cart['id']}, 商品名: ${cart['name']}, 価格: ${cart['price']}');
          }
        }

        return data['carts'];
      } else {
        if (kDebugMode) {
          print('[デバッグ-023] お気に入りの取得に失敗しました: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-023] エラー: $e');
      }
      return [];
    }
  }

// カート削除
  Future<bool> removeCarts(String productNumber) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-024] トークンが見つかりません');
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/cart/${productNumber.toString()}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('[デバッグ-024] 🚀 DELETE送信先: $url');
        print('[デバッグ-024] 📨 ステータスコード: ${response.statusCode}');
        print('[デバッグ-024] 📨 レスポンスボディ: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[デバッグ-024] カートから削除しました');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('[デバッグ-024] カートからの削除に失敗しました: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-024] エラー: $e');
      }
      return false;
    }
  }

// APIサービス内のpaymentLink関数
  Future<Map<String, dynamic>?> paymentLink() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-025] トークンが見つかりません');
      }
      return null;
    }

    final url = Uri.parse('$baseUrl/payment-link');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // JSON全体を返す
      } else {
        if (kDebugMode) {
          print('[デバッグ-025] Failed to receive payment link: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-025] Error: $e');
      }
      return null;
    }
  }

  Future<String> checkOrderStatus(String orderNumber) async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/check-order-status');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_number': orderNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'unknown';
      } else if (response.statusCode == 404) {
        throw '注文が見つかりません';
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? '未知のエラーが発生しました';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-026] エラー: $e');
      }
      throw 'ステータス確認中にエラーが発生しました';
    }
  }

  Future<Map<String, dynamic>?> getOrder(String orderNumber) async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/get-order');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_number': orderNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        if (kDebugMode) {
          print('[デバッグ-027] 注文情報の取得に失敗しました: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-027] エラーが発生しました: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> getOrderAll() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-028] トークンが見つかりません');
      }
      return {};
    }

    final url = Uri.parse('$baseUrl/get-order-all');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-028] result_usage: ${data['result_usage']}');
        }
        return {
          'data': data['data'] ?? [],
          'result_usage': data['result_usage'] ?? []
        };
      } else {
        if (kDebugMode) {
          print('[デバッグ-028] ステータスコード: ${response.statusCode}');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-028] エラー: $e');
      }
      return {};
    }
  }

  Future<Map<String, dynamic>> verifyLicense({
    required int productNumber,
    required String licenseId,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/verify-license');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_number': productNumber,
          'license_id': licenseId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (kDebugMode) {
          print('[デバッグ-029] レスポンスステータス: ${response.statusCode}');
          print('[デバッグ-029] レスポンスボディ: $data');
        }

        if (data.containsKey('success') && data.containsKey('message')) {
          return data;
        } else {
          throw 'レスポンスフォーマットが不正です: $data';
        }
      } else {
        throw 'HTTPエラー: ステータスコード ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-029] エラー: $e');
      }
      throw 'ステータス確認中にエラーが発生しました';
    }
  }

  Future<Map<String, dynamic>> calculate({
    required int productNumber,
    required String licenseId,
    required String productName,
    required String rotation,
    required String machineNumber,
    required String initialHits,
    required String totalHits,
  }) async {
    final String? token = await getToken();

    if (token == null || token.isEmpty) {
      throw '認証トークンが見つかりません';
    }

    final Uri url = Uri.parse('$baseUrl/calculate');
    final Map<String, dynamic> body = {
      "product_number": productNumber,
      "license_id": licenseId,
      "product_name": productName,
      "machine_number": machineNumber,
      "rotation": rotation,
      "initial_hits": initialHits,
      "total_hits": totalHits,
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-030] Laravelから受け取ったJSON: $jsonResponse');
        }
        return jsonResponse;
      } else if (response.statusCode == 403) {
        if (kDebugMode) {
          print('[デバッグ-030] 403エラー: 使用回数制限に達しました。');
        }
        return {
          'success': false,
          'message': "本日の使用回数制限（30件）に達しました。また明日ご利用ください。"
        };
      } else {
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          if (kDebugMode) {
            print('[デバッグ-030] エラー受信: $errorResponse');
          }

          return {
            'success': false,
            'message': errorResponse['message'] ??
                "サーバーエラーが発生しました: ${response.statusCode}"
          };
        } catch (e) {
          if (kDebugMode) {
            print('[デバッグ-030] JSONデコード失敗: $e');
          }

          return {
            'success': false,
            'message': "サーバーエラーが発生しました: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-030] APIエラー: $e');
      }
      return {'success': false, 'message': "API呼び出し中にエラーが発生しました: $e"};
    }
  }

// 購入履歴取得
  Future<List<dynamic>> orderIndex() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-031] トークンが見つかりません');
      }
      return [];
    }

    final url = Uri.parse('$baseUrl/get-order');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-031] エラー: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> orderDetail(String orderNumber) async {
    final token = await getToken(); // トークン取得
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-032] トークンが見つかりません');
      }
      return {'success': false, 'message': 'トークンが見つかりません'};
    }

    final url = Uri.parse('$baseUrl/order-detail');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_number': orderNumber}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-032] 注文詳細取得に成功しました: $jsonResponse');
        }
        return jsonResponse;
      } else {
        if (kDebugMode) {
          print('[デバッグ-032] 注文詳細取得に失敗しました: ${response.statusCode}');
        }
        return {
          'success': false,
          'message': '注文詳細取得に失敗しました: ${response.statusCode}'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-032] 注文詳細取得中にエラーが発生しました: $e');
      }
      return {'success': false, 'message': '注文詳細取得中にエラーが発生しました: $e'};
    }
  }

  Future<Map<String, dynamic>> fetchUsageData({
    required String usage_date,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/fetch-usage-data');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'usage_date': usage_date}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (kDebugMode) {
          print('[デバッグ-033] Laravelから受け取ったデータ: $data');
        }

        return data;
      } else {
        throw 'HTTPエラー: ステータスコード ${response.statusCode}';
      }
    } catch (e) {
      throw 'ステータス確認中にエラーが発生しました: $e';
    }
  }

  Future<Map<String, dynamic>> getDataDetail({
    required String resultNumber,
    required int id,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw 'トークンが見つかりません';
    }

    final url = Uri.parse('$baseUrl/get-data-detail');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'result_number': resultNumber,
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (kDebugMode) {
          print('[デバッグ-034] Laravelから受け取ったデータ: $data');
        }

        if (data.containsKey('data') && data['data'] != null) {
          return data['data'];
        } else {
          throw 'レスポンスデータに "data" キーが含まれていません: $data';
        }
      } else {
        throw 'HTTPエラー: ステータスコード ${response.statusCode}';
      }
    } catch (e) {
      throw 'ステータス確認中にエラーが発生しました: $e';
    }
  }

// news情報取得
  Future<List<dynamic>> getNews() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-035] トークンが見つかりません');
      }
      return [];
    }

    final url = Uri.parse('$baseUrl/news-index');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('[デバッグ-035] ニュースリストを取得しました:');
        }

        return data['data'];
      } else {
        if (kDebugMode) {
          print('[デバッグ-035] ニュースの取得に失敗しました: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-035] エラー: $e');
      }
      return [];
    }
  }

// RobotPayment絡みの処理
  Future<String?> startPurchase() async {
    if (kDebugMode) {
      print('[デバッグ-036] 処理開始');
    }

    final token = await getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchase/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('[デバッグ-036] レスポンスステータス: ${response.statusCode}');
        print('[デバッグ-036] レスポンスボディ: ${response.body}');
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final paymentUrl = json['payment_url'];
        if (kDebugMode) {
          print('[デバッグ-036] 受け取ったURL: $paymentUrl');
        }
        return paymentUrl;
      } else {
        if (kDebugMode) {
          print('[デバッグ-036] サーバーエラー: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-036] 通信エラー: $e');
      }
      return null;
    }
  }

// よくある質問取得
  Future<List<dynamic>> getQuestions() async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-037] トークンが見つかりません');
      }
      return [];
    }

    final url = Uri.parse('$baseUrl/questions');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-037] 質問カテゴリを取得しました: ${data['categories']}');
        }
        return data['categories'] ?? [];
      } else {
        if (kDebugMode) {
          print('[デバッグ-037] ステータスコード: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-037] エラー: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> getAnswer(int questionId) async {
    final token = await getToken();
    if (token == null) {
      if (kDebugMode) {
        print('[デバッグ-038] トークンが見つかりません');
      }
      return {};
    }

    final url = Uri.parse('$baseUrl/getAnswer/$questionId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('[デバッグ-038] 回答データ取得成功: ${data['data']}');
        }
        return data['data'] ?? {};
      } else {
        if (kDebugMode) {
          print('[デバッグ-038] 回答データ取得失敗: ${response.statusCode}');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('[デバッグ-038] 通信エラー: $e');
      }
      return {};
    }
  }

// ※※※※※　これより下には入力しない　※※※※※
}
