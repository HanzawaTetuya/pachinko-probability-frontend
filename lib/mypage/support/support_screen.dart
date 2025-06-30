import 'package:flutter/material.dart';
import 'package:system_alpha/mypage/support/contact_screen.dart';
import 'package:system_alpha/mypage/support/support_detail_screen.dart';
import 'package:system_alpha/api/api_service.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<dynamic> _categoriesWithQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final data = await ApiService().getQuestions(); // API
    setState(() {
      _categoriesWithQuestions = data;
      _isLoading = false; // ローディング完了
    });
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildHeader("サポート・ヘルプ"),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'よくある質問',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFFFFFFFF)),
                        ),
                        SizedBox(height: 32),
                        Column(
                          children: _categoriesWithQuestions.map((category) {
                            final String categoryName = category['name'];
                            final List<dynamic> questions =
                                category['questions'];

                            return Container(
                              margin: EdgeInsets.only(bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: questions.map<Widget>((q) {
                                      return buildPaymentMethodRow(
                                        title: q['question'],
                                        maskedNumber: '',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SupportDetailScreen(
                                                      questionId: q['id']),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 50),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'よくある質問に解決方がない場合は直接お問い合わせください。\n下記より、お問い合わせをすることができます。',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              buildButton(
                                  label: 'お問い合わせ',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ContactScreen()),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
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

  Widget buildPaymentMethodRow({
    required String title,
    required String maskedNumber,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xff252525), // ボーダーの色
              width: 1.0, // ボーダーの太さ
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              ),
              Row(
                children: [
                  Text(
                    maskedNumber,
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 2, right: 16),
                    child: Image.asset(
                      'assets/detail-arrow-white.png',
                      width: 7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
