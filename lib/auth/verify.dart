import 'package:flutter/material.dart';
import 'InputPassword.dart';
import 'package:system_alpha/api/api_service.dart';

class VerifyPage extends StatefulWidget {
  final String email;

  VerifyPage({required this.email}); // コンストラクタでemailを必須に

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController codeController = TextEditingController();
  final ApiService apiService = ApiService(); // ApiServiceのインスタンスを作成
  String? _errorMessage;

  Future<void> verifyCode(BuildContext context) async {
    final String code = codeController.text;

    if (code.isEmpty || code.length != 6) {
      setState(() {
        _errorMessage = '6桁の認証コードを入力してください';
      });
      return;
    }

    try {
      final response = await apiService.verifyCode(widget.email, code);

      if (response == null) {
        // レスポンスが null の場合
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('エラー'),
            content: Text('サーバーとの通信に失敗しました。もう一度お試しください。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('閉じる'),
              ),
            ],
          ),
        );
        return;
      }

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InputPassword(email: widget.email)),
        );
      } else {
        setState(() {
          _errorMessage = '認証コードが無効です。再度お試しください。';
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('エラーが発生しました。もう一度お試しください。'),
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
                      'メールアドレスを確認、認証するため、以下にコードを入力してください。\nあなたのメールアドレス: ${widget.email}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF737374),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      '認証コード',
                      controller: codeController,
                      keyboardType: TextInputType.number,
                    ),
                    if (_errorMessage != null) // エラーメッセージがある場合に表示
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
                      onPressed: () async {
                        await verifyCode(context); // 認証を実行
                      },
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

  Widget _buildTextField(
    String labelText, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    double fontSize = 14,
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
