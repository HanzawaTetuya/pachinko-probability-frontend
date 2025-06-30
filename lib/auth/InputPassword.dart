import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/auth/login.dart';

class InputPassword extends StatefulWidget {
  final String email;

  InputPassword({required this.email});

  @override
  _InputPasswordState createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
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
                        padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'パスワードを入力してください',
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
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF737374),
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 16),

                            // パスワード入力フィールド
                            _buildPasswordField(
                              labelText: 'パスワード',
                              isObscured: _isObscuredPassword,
                              controller: passwordController,
                              toggleObscureText: () {
                                setState(() {
                                  _isObscuredPassword = !_isObscuredPassword;
                                });
                              },
                            ),

                            SizedBox(height: 16),

                            // 確認パスワード入力フィールド
                            _buildPasswordField(
                              labelText: 'パスワードの確認',
                              isObscured: _isObscuredConfirmPassword,
                              controller: confirmPasswordController,
                              toggleObscureText: () {
                                setState(() {
                                  _isObscuredConfirmPassword =
                                      !_isObscuredConfirmPassword;
                                });
                              },
                            ),

                            SizedBox(height: 200),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4A14CA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: registerUser, // 登録処理
                              child: Text(
                                '登録する',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFFFFFFFF)),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'アカウントを登録することにより、利用規約とプライバシーポリシー（Cookieの使用）について同意したとみなされます。',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF737374),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ]))));
  }

  // APIを呼び出してユーザー登録を行う
  Future<void> registerUser() async {
    final email = widget.email;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final response =
        await apiService.registerUser(email, password, confirmPassword);

    if (response != null && response.statusCode == 201) {
      // 登録成功時、ダイアログを表示してからログイン画面に遷移
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('確認'),
            content: Text('アカウントが登録されました！ログインをしてください。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (response != null && response.statusCode == 400) {
      // バリデーションエラー
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('入力内容に誤りがあります。再度ご確認ください。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('閉じる'),
            ),
          ],
        ),
      );
    } else if (response != null && response.statusCode == 422) {
      // パスワード不一致エラー
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('パスワードが一致しません。再度ご確認ください。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('閉じる'),
            ),
          ],
        ),
      );
    } else {
      // その他のエラー
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('登録に失敗しました。再度お試しください。'),
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
        Text(
          labelText,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isObscured,
          keyboardType: TextInputType.visiblePassword,
          style: TextStyle(fontSize: 14),
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
