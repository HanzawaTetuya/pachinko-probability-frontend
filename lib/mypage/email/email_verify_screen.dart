import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import '/../mypage/mypage_screen.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;

  EmailVerifyScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EmailVerifyScreenState createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim(); // 入力されたコードを取得しトリム

    if (code.isEmpty || code.length != 6) {
      setState(() {
        _errorMessage = '6桁の認証コードを入力してください';
      });
      return;
    }

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
      // 2秒間待機（擬似的なディレイ）
      await Future.delayed(Duration(seconds: 2));

      // APIサービスを呼び出して認証
      final apiService = ApiService();
      final success = await apiService.verifyEmailCode(code);

      // ローディングインジケーターを非表示
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        // 成功時
        setState(() {
          _errorMessage = null; // エラーメッセージをクリア
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('メールアドレスが正常に更新されました。'),
            backgroundColor: Color(0xFF4A14CA),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Snackbarが表示された後にマイページへ遷移
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyPageScreen()),
        );
      } else {
        // 失敗時
        setState(() {
          _errorMessage = '認証コードが無効です。再度確認してください。';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('認証コードが無効です。再度確認してください。'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // エラー時にローディングインジケーターを確実に消す
      Navigator.of(context, rootNavigator: true).pop();

      // エラーの通知
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("メールアドレス認証"),
            SizedBox(height: 40),
            buildPasswordConfirmationField(
              title: '認証コード',
              subtitle: '※入力したメールアドレス宛にコードを送信しました。',
            ),
            buildButton(
              label: 'コード認証',
              onPressed: _verifyCode,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF4A14CA)),
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
