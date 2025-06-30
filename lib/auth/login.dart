import 'package:flutter/material.dart';
import 'package:system_alpha/auth/AccountCreation.dart';
import 'login_verify.dart';
import 'password_reset_request_page.dart';
import '../common_screen.dart';
import '../api/api_service.dart'; // APIサービスをインポート

class LoginPage extends StatefulWidget {
  final String? loginMessage;
  const LoginPage({this.loginMessage, Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService apiService = ApiService(); // ApiServiceのインスタンスを作成

  bool _isObscured = true;
  String _eyeIcon = 'assets/see.svg';
  bool _rememberMe = false;

  // emailとpassword入力用のコントローラー
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _checkAutoLogin();

    if (widget.loginMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.loginMessage!)),
        );
      });
    }
  }

  void _checkAutoLogin() async {
    final token = await apiService.getToken();

    if (token != null) {
      // 自動ログイン成功 → Systemタブへ
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CommonScreen()),
      );
    }
    // トークンがない場合は何もせずにそのまま表示（ログイン画面が残る）
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // タップで閉じられない
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '情報を確認中...',
                style: TextStyle(color: Colors.white),
              ),
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
                padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'おかえりなさい',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'システムをご利用いただく場合はログインしてください。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 30),
                    // メールアドレス入力
                    _buildTextField(
                      'メールアドレス',
                      controller: emailController,
                    ),
                    SizedBox(height: 16),
                    // パスワード入力フィールド（表示/非表示機能付き）
                    _buildTextField(
                      'パスワード',
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      hasSuffixIcon: true,
                    ),

                    // パスワードをわすれた場合の処理

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PasswordResetRequestPage()),
                          );
                        },
                        child: Text(
                          'パスワードをお忘れの方はこちら',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A14CA),
                          ),
                        ),
                      ),
                    ),


                    Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: MaterialStateBorderSide.resolveWith(
                                (states) => BorderSide(
                                  color: Color(0xffC7C7C7),
                                  width: 1.5,
                                ),
                              ),
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Color(0xFF4A14CA);
                                  }
                                  return Color(0xffFFFFFF);
                                },
                              ),
                            ),
                          ),
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            'ログイン情報を記録する',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 98),

                    // メール認証へボタン
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
                        showLoadingDialog(context); // ローディング開始

                        final response = await apiService.loginUser(
                          emailController.text,
                          passwordController.text,
                        );

                        Navigator.of(context, rootNavigator: true)
                            .pop(); // ローディングを閉じる

                        if (response != null &&
                            response.containsKey('user_id')) {
                          final userId = response['user_id'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginVerifyPage(
                                email: emailController.text,
                                userId: userId.toString(),
                                rememberMe: _rememberMe,
                              ),
                            ),
                          );
                        } else {
                          final message = response != null
                              ? response['message']
                              : 'ログインに失敗しました。メールとパスワードを確認してください。';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'ログイン',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(color: Color(0xFFC7C7C7), height: 1),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountCreationPage()),
                        );
                      },
                      child: Text(
                        'アカウントの作成はこちらから',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF737374)),
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

  Widget _buildTextField(String labelText,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      bool hasSuffixIcon = false,
      double fontSize = 14}) {
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
          obscureText: obscureText && _isObscured,
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
            suffixIcon: hasSuffixIcon
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isObscured = !_isObscured;
                        _eyeIcon = _isObscured
                            ? 'assets/see.svg'
                            : 'assets/no-see.svg';
                      });
                    },
                    child: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
