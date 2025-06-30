import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/mypage/password/edit_password_screen.dart';

class PasswordVerifyScreen extends StatefulWidget {
  @override
  _PasswordVerifyScreenState createState() => _PasswordVerifyScreenState();
}

class _PasswordVerifyScreenState extends State<PasswordVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ApiService apiService = ApiService();
  String? _errorMessage;

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

  Future<void> verifyCode(BuildContext context) async {
    final String code = _codeController.text;

    if (code.isEmpty || code.length != 6) {
      // 必須フィールドのチェック
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('6桁の認証コードを入力してください'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ローディングインジケーターを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // APIを呼び出して認証コードを検証
      final success = await apiService.verifyPasswordCode(code);

      // ローディングインジケーターを非表示
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        // 成功時: 次の画面に遷移
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditPasswordScreen()),
        );
      } else {
        // 認証コードが無効の場合のSnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('認証コードが無効です。再度お試しください。'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ローディングインジケーターを非表示
      Navigator.of(context, rootNavigator: true).pop();

      // エラーが発生した場合のSnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました。もう一度お試しください。'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("本人確認"),
            SizedBox(height: 40),
            buildPasswordConfirmationField(
              title: '認証コード',
              subtitle: '※ご登録のメールアドレス宛にコードを送信しました。',
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Color(0xFFBD4949),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            buildButton(
              label: '本人確認',
              onPressed: () async {
                await verifyCode(context);
              },
            ),
            SizedBox(height: 5),
          ],
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
          TextField(
            controller: _codeController,
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
            keyboardType: TextInputType.number,
            maxLength: 6,
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
}
