import 'package:flutter/material.dart';
import '/../mypage/userinfo_screen.dart'; // UserinfoScreenをインポート
import '../../api/api_service.dart'; // APIサービスをインポート

class EditPasswordScreen extends StatefulWidget {
  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final ApiService _apiService = ApiService();

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }
    if (value.length < 8) {
      return 'パスワードは8文字以上にしてください';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'パスワードには大文字を1文字以上含めてください';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'パスワードには小文字を1文字以上含めてください';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'パスワードには数字を1文字以上含めてください';
    }
    return null;
  }

  String? validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワード確認を入力してください';
    }
    if (value != _passwordController.text) {
      return 'パスワードが一致しません';
    }
    return null;
  }

  Future<void> _submitPassword() async {
    if (_formKey.currentState!.validate()) {
      final String password = _passwordController.text;
      final String passwordConfirmation = _passwordConfirmationController.text;

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
        // 2秒間のディレイを挿入（API呼び出しのシミュレーション）
        await Future.delayed(Duration(seconds: 2));

        // サーバーにパスワードを送信
        final bool success =
            await _apiService.updatePassword(password, passwordConfirmation);

        // ローディングインジケーターを非表示
        Navigator.of(context, rootNavigator: true).pop();

        if (success) {
          // 成功時
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('パスワードの更新が完了しました'),
              backgroundColor: Color(0xFF4A14CA),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );

          // Snackbarが表示された後にUserinfoScreenに遷移
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserinfoScreen()),
            );
          });
        } else {
          // パスワード更新失敗時のSnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('パスワードの更新に失敗しました。再度お試しください。'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // ローディングインジケーターを非表示
        Navigator.of(context, rootNavigator: true).pop();

        // エラー発生時のSnackBar
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
              buildPasswordField(
                controller: _passwordController,
                title: '新しいパスワード',
                subtitle: '※以前使用していたパスワードは使うことができません。',
                validator: validatePassword,
              ),
              SizedBox(height: 20),
              buildPasswordField(
                controller: _passwordConfirmationController,
                title: 'パスワードの確認',
                validator: validatePasswordConfirmation,
              ),
              buildButton(
                label: '更新',
                onPressed: _submitPassword, // パスワード送信処理を実行
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String title,
    String? subtitle,
    required String? Function(String?) validator,
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
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF4A14CA)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            obscureText: true,
            validator: validator,
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
