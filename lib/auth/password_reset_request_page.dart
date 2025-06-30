import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'password_reset_verify.dart'; // ← 認証コード入力画面に遷移する想定

class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({Key? key}) : super(key: key);

  @override
  State<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  final TextEditingController emailController = TextEditingController();
  final ApiService apiService = ApiService();

  Future<void> _submitEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メールアドレスを入力してください。')),
      );
      return;
    }

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
              'メールアドレスを照合中...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    final response = await apiService.forgotPasswordInLogin(email);

    Navigator.of(context, rootNavigator: true).pop(); // ローディング非表示

    if (response != null && response['success'] == true) {
      // 認証コード画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PasswordResetVerifyPage(email: email),
        ),
      );
    } else {
      final message = response?['message'] ?? 'エラーが発生しました。もう一度お試しください。';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildTextField(String labelText,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.emailAddress,
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
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF01020C),
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 40),
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
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/back-button.png',
                          width: 15,
                          height: 23,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'パスワードの再設定',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ご登録のメールアドレスを入力してください。認証コードをメールでお送りします。',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF737374),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    _buildTextField('メールアドレス', controller: emailController),
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
                      onPressed: _submitEmail,
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
}
