import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/auth/login.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  final String email;

  const PasswordResetConfirmPage({required this.email, Key? key})
      : super(key: key);

  @override
  _PasswordResetConfirmPageState createState() =>
      _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends State<PasswordResetConfirmPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isObscuredPassword = true;
  bool _isObscuredConfirmPassword = true;
  final ApiService apiService = ApiService();

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
                child:
                    Image.asset('assets/main-logo.png', width: 130, height: 30),
              ),
              SizedBox(height: 40),
              Container(
                width: 380,
                padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '新しいパスワードを入力してください',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'アルファベット大文字小文字を少なくても１文字以上は使い、８文字以上で作成してください。',
                      style: TextStyle(fontSize: 10, color: Color(0xFF737374)),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      labelText: 'パスワード',
                      isObscured: _isObscuredPassword,
                      controller: passwordController,
                      toggleObscureText: () {
                        setState(
                            () => _isObscuredPassword = !_isObscuredPassword);
                      },
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      labelText: 'パスワードの確認',
                      isObscured: _isObscuredConfirmPassword,
                      controller: confirmPasswordController,
                      toggleObscureText: () {
                        setState(() => _isObscuredConfirmPassword =
                            !_isObscuredConfirmPassword);
                      },
                    ),
                    SizedBox(height: 200),
                    ElevatedButton(
                      onPressed: resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A14CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('変更する',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '※頻繁にパスワードの変更が行われるとアカウントがロックされてしまう恐れがあります。パスワードはお忘れになられないようよろしくお願いいたします。',
                      style: TextStyle(fontSize: 10, color: Color(0xFF737374)),
                      textAlign: TextAlign.left,
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

  Future<void> resetPassword() async {
    final email = widget.email;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final response =
        await apiService.resetPasswordInLogin(email, password, confirmPassword);

    if (response != null && response['success'] == true) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('完了'),
          content: Text('パスワードを再設定しました。ログインしてください。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('エラー'),
          content: Text(response?['message'] ?? 'エラーが発生しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('閉じる'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPasswordField({
    required String labelText,
    required bool isObscured,
    required TextEditingController controller,
    required VoidCallback toggleObscureText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isObscured,
          keyboardType: TextInputType.visiblePassword,
          style: TextStyle(fontSize: 14),
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
            suffixIcon: GestureDetector(
              onTap: toggleObscureText,
              child: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
