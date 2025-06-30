import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/mypage/password/password_verify_screen.dart';

class UpdatePasswordScreen extends StatefulWidget {
  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService(); // ApiServiceのインスタンス
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage; // エラーメッセージを表示するための変数

  Future<void> _sendPassword() async {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text;

      // ローディングインジケーターを表示
      showDialog(
        context: context,
        barrierDismissible: false, // タップで閉じられないように設定
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // 2秒間のディレイを挿入（API呼び出しのシミュレーションA）
        await Future.delayed(Duration(seconds: 2));

        // APIを呼び出してパスワードを送信
        final success = await apiService.editPassword(password);

        // ローディングインジケーターを非表示
        Navigator.of(context, rootNavigator: true).pop();

        if (success) {
          // 次の画面に遷移
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordVerifyScreen()),
          );
        } else {
          // 送信失敗時のエラーメッセージをSnackBarで表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('パスワードの送信に失敗しました。もう一度お試しください。'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // ローディングインジケーターを非表示
        Navigator.of(context, rootNavigator: true).pop();

        // エラー発生時の通知をSnackBarで表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader("パスワード変更"),
              SizedBox(height: 40),
              buildPasswordConfirmationField(
                title: 'パスワードの確認',
                subtitle: '※既存のパスワードを入力して下さい。',
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Color(0xFFBD4949), // エラーメッセージの色
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              buildButton(
                label: '次へ',
                onPressed: _sendPassword, // パスワード送信を実行
              ),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      // ローディング表示
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(child: CircularProgressIndicator());
                        },
                      );

                      final success = await apiService.forgotPasswordInMypage();

                      Navigator.of(context, rootNavigator: true)
                          .pop(); // ← 必ずローディングを閉じる

                      if (success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordVerifyScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('認証コードの送信に失敗しました。もう一度お試しください。'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // エラー時にも必ずローディング終了
                      print('🚨 エラー: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('通信エラーが発生しました。'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'パスワードをお忘れの方',
                    style: TextStyle(
                      color: Color(0xFF818181),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordConfirmationField({
    required String title,
    String? subtitle,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF818181),
                fontSize: 12,
              ),
            ),
          ],
          SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'パスワードを入力してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    double topPadding = 40.0,
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding),
        Container(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A14CA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        Container(width: 24, height: 24),
      ],
    );
  }
}
