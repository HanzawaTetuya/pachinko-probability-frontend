import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'passwordResetConfirmPage.dart';

class PasswordResetVerifyPage extends StatefulWidget {
  final String email;

  PasswordResetVerifyPage({required this.email, Key? key}) : super(key: key);

  @override
  State<PasswordResetVerifyPage> createState() => _PasswordResetVerifyPageState();
}

class _PasswordResetVerifyPageState extends State<PasswordResetVerifyPage> {
  final TextEditingController codeController = TextEditingController();
  final ApiService apiService = ApiService();

  Future<void> _submitCode() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('認証コードを入力してください。')),
      );
      return;
    }

    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '認証コードを確認中...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    final response = await apiService.verifyResetPasswordCode(
      widget.email,
      code,
    );

    Navigator.of(context, rootNavigator: true).pop(); // ローディング非表示

    if (response != null && response['success'] == true) {
  // 認証成功時のSnackBar表示＋画面遷移
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('認証が完了しました')),
  );

  // 1秒後に次の画面へ遷移
  await Future.delayed(Duration(seconds: 1));

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => PasswordResetConfirmPage(email: widget.email),
    ),
  );
} else {
  final msg = response?['message'] ?? '認証に失敗しました。';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg)),
  );
}

  }

  Widget _buildTextField(String labelText,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text,
      double fontSize = 14}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xffC7C7C7), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF4A14CA), width: 2.0),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    return Scaffold(
      backgroundColor: Color(0xFF01020C),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/main-logo.png', width: 130, height: 30),
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
                        onTap: () => Navigator.pop(context),
                        child: Image.asset('assets/back-button.png',
                            width: 15, height: 23),
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
                      'メールに届いた認証コードを入力してください。\nあなたのメールアドレス: $email',
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
                      onPressed: _submitCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A14CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        '次へ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
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
}
