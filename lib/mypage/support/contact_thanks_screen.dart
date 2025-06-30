import 'package:flutter/material.dart';
import 'package:system_alpha/common_screen.dart';

class ContactThanksScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ContactThanksScreen> {
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
              _buildHeader("お問い合わせ完了"),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text(
                      'お問い合わせいただきありがとうございます。',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'お問い合わせを受け付けました。通常２４時間以内にご返信いたしております。順番に対応させていただきますので、もうしばらくお待ちください。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    buildButton(
                        label: 'ホームに戻る',
                        onPressed: () {
                          final commonState = context
                              .findAncestorStateOfType<CommonScreenState>();
                          if (commonState != null) {
                            commonState.onItemTapped(0); // ホームタブへ
                            Navigator.pop(context); // Thanks画面を閉じるだけでOK
                          } else {
                            // fallback: 初期画面に戻る必要があるなら下記
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CommonScreen(initialIndex: 0)),
                              (Route<dynamic> route) => false,
                            );
                          }
                        })
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

Widget buildTextField({
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          maxLines: null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
