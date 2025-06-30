import 'package:flutter/material.dart';
import 'package:system_alpha/auth/login.dart';
import 'package:system_alpha/auth/verify.dart';
import 'package:system_alpha/api/api_service.dart';

class AccountCreationPage extends StatelessWidget {
  final String? referralCode;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  final _formKey = GlobalKey<FormState>();

  AccountCreationPage({Key? key, this.referralCode}) : super(key: key);

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('登録処理中...', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF01020C), // 背景色を指定
        body: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(), // ← のびるスクロール感
              padding: EdgeInsets.only(
                  left: 16, right: 16, top: 20, bottom: 40), // 下にも余白追加
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ヘッダー部分のアイコン
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Image.asset(
                      'assets/main-logo.png', // 画像ファイルのパス
                      width: 130,
                      height: 30,
                    ),
                  ),
                  SizedBox(height: 40),
                  // フォーム部分
                  Container(
                    width: 380, // 画面幅の80%
                    padding: EdgeInsets.fromLTRB(
                        20, 40, 20, 30), // 左: 20, 上: 40, 右: 20, 下: 30
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'システムαアカウントを作成',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          referralCode != null
                              ? '紹介コード: $referralCode'
                              : '紹介コードは指定されていません',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '必要事項を入力して下さい',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30),

                        // ユーザーネーム
                        _buildTextField(
                          'ユーザーネーム',
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ユーザーネームを入力してください';
                            }
                            return null;
                          },
                        ),

// メールアドレス
                        _buildTextField(
                          'メールアドレス',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            final emailRegex = RegExp(
                                r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$'); // シンプルなemail形式チェック
                            if (!emailRegex.hasMatch(value)) {
                              return '有効なメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),

// 生年月日
                        _buildTextField(
                          '生年月日',
                          controller: dobController,
                          keyboardType: TextInputType.datetime,
                          hintText: '例）1990-01-01',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '生年月日を入力してください';
                            }
                            final dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!dobRegex.hasMatch(value)) {
                              return '生年月日は「YYYY-MM-DD」の形式で入力してください';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 98),

                        // メール認証へボタン
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A14CA), // ボタンの背景色
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            minimumSize: Size(double.infinity, 50), // 幅を100%に
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _sendAccountData(context);
                            }
                          },
                          child: Text(
                            'メール認証へ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFFFFF)), // テキストカラー変更
                          ),
                        ),
                        SizedBox(height: 16),

                        Divider(color: Color(0xFFC7C7C7), height: 1),

                        // ログインリンク
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage()), // login.dartのページへ遷移
                            );
                          },
                          child: Text(
                            'ログインはこちらから',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF737374)), // フォントカラーを変更
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // サーバーにアカウントデータを送信するメソッド
  Future<void> _sendAccountData(BuildContext context) async {
    showLoadingDialog(context); // 表示

    final username = usernameController.text;
    final email = emailController.text;
    final dob = dobController.text;

    final response = await ApiService().createAccount(
      username,
      email,
      dob,
      referralCode: referralCode,
    );

    Navigator.of(context, rootNavigator: true).pop(); // ダイアログを閉じる

    if (response != null && response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyPage(email: email)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('エラー'),
          content: Text('アカウントの作成に失敗しました。再度お試しください。'),
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

  // テキストフィールドのウィジェットを再利用
  Widget _buildTextField(
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    double fontSize = 14,
    String? hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: fontSize),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
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
}
