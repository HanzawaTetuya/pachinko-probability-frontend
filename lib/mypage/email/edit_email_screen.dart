import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import 'email_verify_screen.dart';

class EditEmailScreen extends StatefulWidget {
  final String? currentEmail;

  EditEmailScreen({Key? key, this.currentEmail}) : super(key: key);

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveEmailAndProceed() async {
    if (_formKey.currentState!.validate()) {
      final newEmail = _emailController.text;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
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

          // APIを呼び出してメールアドレスを更新
          final success = await apiService.editEmail(newEmail);

          // ローディングインジケーターを非表示
          Navigator.of(context, rootNavigator: true).pop();

          if (success) {
            // 成功時
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EmailVerifyScreen(email: newEmail), // 次の画面にemailを渡す
              ),
            );
          } else {
            // 失敗時
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('メールの送信に失敗しました。'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // ローディングインジケーターを非表示
          Navigator.of(context, rootNavigator: true).pop();

          // エラー発生時
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // トークンがない場合のエラーメッセージ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('認証トークンが見つかりません。再度ログインしてください。'),
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
              _buildHeader("メールアドレスの変更"),
              SizedBox(height: 40),
              buildPasswordConfirmationField(
                title: 'メールアドレス',
                subtitle: '※有効なメールアドレスを入力してください。',
                currentEmail: widget.currentEmail,
              ),
              buildButton(
                label: 'メールアドレス認証へ',
                onPressed: _saveEmailAndProceed,
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordConfirmationField({
    required String title,
    String? subtitle,
    String? currentEmail,
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
            controller: _emailController,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'メールアドレスを入力してください';
              } else if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
                return '有効なメールアドレスを入力してください';
              }
              return null;
            },
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
