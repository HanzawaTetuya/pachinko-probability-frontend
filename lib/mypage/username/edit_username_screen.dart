import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart'; // APIサービスのインポート
import 'package:system_alpha/mypage/mypage_screen.dart';
import 'package:system_alpha/mypage/userinfo_screen.dart'; // マイページへの遷移

class EditUsernameScreen extends StatefulWidget {
  final String? currentName;

  EditUsernameScreen({Key? key, this.currentName}) : super(key: key);

  @override
  _EditUsernameScreenState createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  late TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  final ApiService _apiService = ApiService(); // APIサービスのインスタンス

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    if (_formKey.currentState!.validate()) {
      final newUserName = _usernameController.text;

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
        // 2秒間待機（API呼び出しまでのディレイ）
        await Future.delayed(Duration(seconds: 2));

        // APIを呼び出してユーザー名を更新
        final success = await _apiService.editUserName(newUserName);

        // ローディングインジケーターを非表示
        Navigator.of(context, rootNavigator: true).pop();

        if (success) {
          // 成功時
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ユーザー名が正常に更新されました。'),
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
          // 失敗時
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ユーザー名の更新に失敗しました。再度お試しください。'),
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
              _buildHeader("ユーザーネームの変更"),
              SizedBox(height: 40),
              buildPasswordConfirmationField(
                title: '新しいユーザーネーム',
                subtitle: '※ユーザーネームはあとから変更できます。\n※半角英数字8文字以上で入力してください。',
                currentName: widget.currentName,
              ),
              if (_errorMessage != null)
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
              buildButton(
                label: '変更',
                onPressed: _updateUsername,
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
    String? currentName,
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
            controller: _usernameController,
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
                return 'ユーザーネームを入力してください';
              } else if (value.length < 8) {
                return 'ユーザーネームは8文字以上で入力してください';
              } else if (value.length > 255) {
                return 'ユーザーネームは255文字以内で入力してください';
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
