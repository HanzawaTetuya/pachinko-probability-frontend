import 'package:flutter/material.dart';
import 'news_detail_screen.dart';
import 'package:system_alpha/api/api_service.dart'; // APIをインポート
import 'package:intl/intl.dart';

class NewsScreen extends StatelessWidget {
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
      backgroundColor: Colors.black,
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getNews(), // APIを呼び出してデータを取得
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // データ取得中のインジケーターを表示
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // エラー時にメッセージを表示
            return Center(
              child: Text(
                'データの取得中にエラーが発生しました',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // データが空の場合の表示
            return Center(
              child: Text(
                'お知らせはまだありません',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // データが正常に取得できた場合
          final newsList = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final newsItem = newsList[index];
              // タグの取得（複数タグがある場合の処理）
              final tagNames = (newsItem['tags'] as List<dynamic>)
                  .map((tag) => tag['name'])
                  .join(', '); // カンマ区切りで結合
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewsDetailScreen(newsData: newsItem), // データを渡す
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff252525), // ボーダーの色
                        width: 1.0, // ボーダーの太さ
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 要素の左側
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タグ
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // 背景色
                                    borderRadius:
                                        BorderRadius.circular(5), // 角丸
                                  ),
                                  child: Text(
                                    tagNames,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A14CA)),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${formatDate(newsItem['published_at'])}', // フォーマットした日付を表示
                                  style: TextStyle(color: Color(0xFF737374)),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            // タイトル
                            Text(
                              '${newsItem['title'] ?? 'タイトルなし'}', // タイトルを表示
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: 2, // 長い場合は1行でカット
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // 要素の右側
                      Image.asset(
                        'assets/test-top-img.png', // 戻るボタンの画像パス
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
