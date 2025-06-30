import 'package:flutter/material.dart';
import 'package:system_alpha/auth/login.dart';
import 'package:system_alpha/mypage/payment/payment_method_screen.dart';
import 'package:system_alpha/mypage/username/edit_username_screen.dart';
import '../api/api_service.dart';
import 'password/update_password_screen.dart';
import 'email/edit_email_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserinfoScreen extends StatefulWidget {
  @override
  _UserinfoScreenState createState() => _UserinfoScreenState();
}

class _UserinfoScreenState extends State<UserinfoScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? userInfo; // ユーザー情報を保持する変数
  bool isLoading = true; // 読み込み中かどうかを管理

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 初期化時にユーザー情報を取得
  }

  // APIからユーザー情報を取得するメソッド
  Future<void> _fetchUserInfo() async {
    // トークンを SharedPreferences から取得
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // ここでトークンをログ出力して、正しく取得できているか確認
    print('アクセストークン: $token');

    // アクセストークンが存在しない場合、エラーメッセージを表示して処理を中断
    if (token == null) {
      print('アクセストークンが見つかりません');
      setState(() {
        userInfo = {'error': 'アクセストークンが見つかりません'};
        isLoading = false;
      });
      return;
    }

    // ApiService クラスを呼び出してユーザー情報を取得
    final data = await apiService.getUserInfo();
    print('取得したユーザー情報: $data'); // 取得したユーザー情報のデバッグ出力

    // 取得結果をセット
    setState(() {
      userInfo = data;
      isLoading = false; // 読み込み完了
    });
  }

  // ヘッダーウィジェット
  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.asset(
              'assets/back-button.png',
              width: 24,
              height: 24,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Container(width: 24, height: 24), // 空白
      ],
    );
  }

  // 各情報行を表示するメソッド
  Widget _buildInfoRow(String title, String value,
      {bool hasIcon = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (hasIcon)
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 2),
                    child: Image.asset(
                      'assets/mypage/user-detail.png',
                      width: 7,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 支払管理とログアウトボタンを表示するメソッド
  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ローディングインジケーター
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(), // ← のびるスクロール感
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildHeader("会員情報"),
                  SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xffA0A0A0), width: 1.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'ユーザーネーム',
                                userInfo?['name'] ?? '不明',
                                hasIcon: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUsernameScreen(
                                        currentName:
                                            userInfo?['name'], // オプショナル引数として渡す
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              _buildInfoRow(
                                'メールアドレス',
                                userInfo?['email'] ?? '不明',
                                hasIcon: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEmailScreen(
                                        currentEmail:
                                            userInfo?['email'], // オプショナル引数として渡す
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10),
                              _buildInfoRow(
                                '生年月日',
                                userInfo?['birth_date'] ?? '不明',
                              ),
                              SizedBox(height: 10),
                              _buildInfoRow(
                                'パスワード',
                                '***************',
                                hasIcon: true,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UpdatePasswordScreen()));
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
