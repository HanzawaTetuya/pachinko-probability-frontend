import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // ← これが必要！
import '../common_screen.dart';
import '../api/api_service.dart';

class LoginVerifyPage extends StatelessWidget {
  final String email;
  final String userId; // ユーザーIDを保持するフィールド
  final bool rememberMe;
  final TextEditingController codeController = TextEditingController();
  final ApiService apiService = ApiService();

  LoginVerifyPage({
    required this.email,
    required this.userId,
    required this.rememberMe,
  });

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '情報を確認中...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> verifyCode(BuildContext context) async {
    final String code = codeController.text;

    // ✅ ローディング表示（共通関数）
    showLoadingDialog(context);

    final response = await apiService.verifyLoginCode(userId, code);

    // ✅ ローディング非表示
    Navigator.of(context, rootNavigator: true).pop();

    if (response != null) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['access_token'] != null) {
        final token = body['access_token'];

        if (rememberMe && token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CommonScreen(initialIndex: 0),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('認証に失敗しました。認証コードを確認してください。'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('サーバーからの応答がありませんでした。'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF01020C),
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(), // ← のびるスクロール感
          padding: EdgeInsets.only(
              left: 16, right: 16, top: 20, bottom: 40), // 下にも余白追加
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'assets/main-logo.png',
                  width: 130,
                  height: 30,
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: 380,
                padding: EdgeInsets.fromLTRB(20, 18, 20, 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          'assets/back-button.png',
                          width: 15,
                          height: 23,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      '認証コードを送信しました',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'メールアドレスを確認、認証するため、以下にコードを入力してください。\nあなたのメールアドレス: $email',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF737374),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    _buildTextField('認証コード', controller: codeController),
                    SizedBox(height: 266),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A14CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () => verifyCode(context),
                      child: Text(
                        '次へ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text,
      double fontSize = 14}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color(0xffC7C7C7),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color(0xFF4A14CA),
                width: 2.0,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
