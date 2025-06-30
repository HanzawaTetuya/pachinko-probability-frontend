import 'package:flutter/material.dart';
import '/../mypage/mypage_screen.dart';

class EditPaymentMethodScreen extends StatefulWidget {
  @override
  _EditPaymentMethodScreenState createState() =>
      _EditPaymentMethodScreenState();
}

class _EditPaymentMethodScreenState extends State<EditPaymentMethodScreen> {
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("支払方法"),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'お支払方法の編集',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  buildPasswordConfirmationField(title: 'カードの名義'),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '有効期限 (月)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0xFFC7C7C7), // 非フォーカス時のボーダー色
                              ),
                            ),
                          ),
                          items: List.generate(12, (index) {
                            final month =
                                (index + 1).toString().padLeft(2, '0');
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }),
                          onChanged: (value) {},
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '有効期限 (年)',
                            fillColor: Color(0xffFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color(0xFFC7C7C7), // 非フォーカス時のボーダー色
                              ),
                            ),
                          ),
                          items: List.generate(10, (index) {
                            final year =
                                (DateTime.now().year + index).toString();
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                  buildButton(
                      label: '変更',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyPageScreen()),
                        );
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordConfirmationField({
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
              color: Color(0xFF000000),
              fontSize: 12,
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
          SizedBox(
              height: subtitle != null ? 8 : 8), // サブタイトルがあるときは16、ないときは8の余白
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFC7C7C7)), // 有効時のボーダー色
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Color(0xFF4A14CA)), // フォーカス時のボーダー色
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    double topPadding = 40.0, // デフォルトの上部余白を設定
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
