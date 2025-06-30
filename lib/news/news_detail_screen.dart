import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsData; // データを受け取る

  const NewsDetailScreen({Key? key, required this.newsData}) : super(key: key);

  String formatDate(String? isoDate) {
    if (isoDate == null) return '日付不明';
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy年MM月dd日').format(dateTime);
    } catch (e) {
      return '日付不明';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),

      // メインコンテンツ
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        child: Column(
          children: [
            // backbutton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // 戻るボタンのアクション
                    },
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
                ],
              ),
            ),
            SizedBox(height: 10),

            // メインコンテンツ
            Container(
              child: Column(
                children: [
                  Image.asset(
                    'assets/img-big.png', // デフォルト画像を表示
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsData['title'] ?? 'タイトルなし', // タイトルを動的に表示
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        // タグと日付
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                newsData['tag'] ?? 'お知らせ', // タグを表示
                                style: TextStyle(
                                  color: Color(0xFF4A14CA),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${formatDate(newsData['published_at'])}', // フォーマットした日付を表示
                              style: TextStyle(
                                color: Color(0xFF737374),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // 内容
                        Text(
                          newsData['content'] ?? '内容がありません', // 内容を動的に表示
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
