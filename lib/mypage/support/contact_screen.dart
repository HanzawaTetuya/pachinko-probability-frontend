import 'package:flutter/material.dart';
import 'package:system_alpha/mypage/support/contact_thanks_screen.dart';
import 'package:system_alpha/api/api_service.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _subjectLength = 0;
  int _messageLength = 0;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _subjectController.addListener(() {
      setState(() {
        _subjectLength = _subjectController.text.length;
      });
    });
    _messageController.addListener(() {
      setState(() {
        _messageLength = _messageController.text.length;
      });
    });
  }

  Widget buildTextField({
    required String title,
    String? subtitle,
    required TextEditingController controller,
    required int maxLength,
    required int currentLength,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF01020C),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: controller,
                maxLength: maxLength,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 30),
                  counterText: '', // デフォルトカウンター非表示
                ),
              ),
              Positioned(
                bottom: 8,
                right: 12,
                child: Text(
                  '$currentLength / $maxLength',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF818181),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildLargeTextField({
    required String title, // 1つ目のTextの内容
    String? subtitle, // 2つ目のTextの内容（nullの場合は非表示）
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF01020C),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8), // タイトルとTextFieldの間の余白
          TextField(
            controller: _messageController, // 追加
            maxLines: null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8), // TextFieldとサブタイトルの間の余白
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF818181),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ヘッダーウィジェット
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
        Container(width: 24, height: 24), // 空白
      ],
    );
  }
  // 支払管理とログアウトボタンを表示するメソッド

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),

      // メインコンテンツ
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildHeader("お問い合わせ"),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    buildTextField(
                      title: 'お問い合わせ内容',
                      subtitle:
                          'お問い合わせ内容にはどのようなことについてなのかを記載してください。\n例）お支払いについて。サービス利用について。など',
                      controller: _subjectController, // 追加
                      maxLength: 100, // 入力制限
                      currentLength: _subjectLength,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '本文',
                            style: TextStyle(
                              color: Color(0xFF01020C),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 233, // 高さ固定
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _messageController,
                                  maxLength: 500,
                                  maxLines: 12, // 行数で高さをある程度制御
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        16, 12, 16, 30), // 下に余白追加
                                    counterText: '', // デフォルトカウンター非表示
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 12,
                                  child: Text(
                                    '$_messageLength / 500',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // タイトルとTextFieldの間の余白

                          buildButton(
                            label: '送信する',
                            onPressed: () async {
                              final subject = _subjectController.text.trim();
                              final message = _messageController.text.trim();

                              if (subject.isEmpty || message.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('件名と内容の両方を入力してください。'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // ローディング表示
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    Center(child: CircularProgressIndicator()),
                              );

                              // ✅ 強制的に2秒間ローディングを維持
                              await Future.delayed(Duration(seconds: 2));

                              final result = await apiService.sendInquiry(
                                  subject, message);

                              Navigator.of(context, rootNavigator: true)
                                  .pop(); // ローディング閉じる

                              if (result == null) {
                                // 成功：サンクス画面に遷移
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ContactThanksScreen()),
                                );
                              } else {
                                // エラー表示（バリデーションメッセージなど）
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('ボタンを押すと、登録いただいているメールアドレスから弊社にメールが送信されます。',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xffADADAD))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    double topPadding = 20.0, // デフォルトの上部余白を設定
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding), // ボタン上部の余白
        Container(
          width: double.infinity, // 横幅を画面いっぱいに
          height: 44, // 高さを44に設定
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A14CA), // ボタンの背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // ボタンの角丸
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
}
