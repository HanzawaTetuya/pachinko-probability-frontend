import 'package:flutter/material.dart';
import 'package:system_alpha/common_screen.dart';
import 'package:intl/intl.dart';
import 'package:system_alpha/news/news_detail_screen.dart';
import 'package:system_alpha/product/product_detail_screen.dart';
import 'package:system_alpha/models/product.dart'; // Productモデルをインポート
import 'package:system_alpha/api/api_service.dart';

// カスタムペインターを使って点線の下線を描画
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color // 線の色
      ..strokeWidth = 1 // 線の太さ
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 3;
    var dashSpace = 3;
    double startX = 0;

    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> usageData;
  final Map<String, dynamic> product;
  final List<dynamic> newsData;

  const HomeScreen({
    Key? key,
    required this.userInfo,
    required this.usageData,
    required this.product,
    required this.newsData,
  }) : super(key: key);

  @override

  // 数値フォーマット関数
  String formatPrice(dynamic price) {
    if (price == null) return 'なし'; // null時の処理
    try {
      final formatter = NumberFormat('#,###');
      return formatter.format(double.parse(price.toString()));
    } catch (e) {
      return '不明'; // パースエラー時
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '使用履歴がありません。';
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      final formatter = DateFormat('yyyy年MM月dd日');
      return formatter.format(dateTime);
    } catch (e) {
      return '不明';
    }
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(), // ← のびるスクロール感
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          // ユーザー情報表示
          Column(
            children: [
              // ユーザー情報ヘッダー
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 子要素を左右に均等に配置
                children: [
                  Text(
                    'ユーザー情報',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffffff)),
                  ),

                  // 詳細ボタン
                  // リンク機能付与
                  GestureDetector(
                    onTap: () {
                      // CommonScreenState にアクセスして index を更新
                      final commonState =
                          context.findAncestorStateOfType<CommonScreenState>();
                      commonState?.onItemTapped(4); // 4はマイページのインデックス
                    },
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 子ウィジェットを上揃え
                      children: [
                        Text(
                          '詳細',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFffffff)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // 矢印
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0), // 上から3pxの余白を追加して下にずらす
                          child: Image.asset(
                            'assets/home/detail-button.png',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              // 点線との幅
              SizedBox(
                height: 6,
              ),

              // 点線のボーダーを追加
              CustomPaint(
                painter:
                    DashedLinePainter(color: Colors.white), // カスタムペインターで点線を描画
                child: Container(
                  height: 1,
                  width: double.infinity, // Rowと同じ幅にする
                ),
              ),

              SizedBox(height: 10),

              // メインコンテンツ（例として空のコンテナ）
              Container(
                width: double.infinity,
                // height: 60,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),

                // 内部コンテンツIMGとtextエリアの横並び
                child: Row(
                  children: [
                    SizedBox(
                      width: 19,
                    ),
                    Image.asset(
                      'assets/home/user-icon.png',
                      width: 31,
                      height: 31,
                    ), // 例としてアイコンを追加（画像の代わりに）
                    SizedBox(width: 15), // アイコンとテキストの間に余白
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ユーザーネーム：${userInfo['name'] ?? 'ユーザーネームの取得に失敗しました。'}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'メールアドレス：${userInfo['email'] ?? 'メールアドレスの取得に失敗しました。'}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: 30,
          ),

          // 使用履歴表示
          Column(
            children: [
              // ユーザー情報ヘッダー
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 子要素を左右に均等に配置
                children: [
                  Text(
                    '使用履歴',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffffff)),
                  ),

                  // 詳細ボタン
                  // リンク機能付与
                  GestureDetector(
                    onTap: () {
                      // CommonScreenState にアクセスして index を更新
                      final commonState =
                          context.findAncestorStateOfType<CommonScreenState>();
                      commonState?.onItemTapped(2); // 4はマイページのインデックス
                    },
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // ✅ UIはそのまま
                      children: [
                        Text(
                          '詳細',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFffffff)),
                        ),
                        SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Image.asset(
                            'assets/home/detail-button.png',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 点線との幅
              SizedBox(
                height: 6,
              ),

              // 点線のボーダーを追加
              CustomPaint(
                painter:
                    DashedLinePainter(color: Colors.white), // カスタムペインターで点線を描画
                child: Container(
                  height: 1,
                  width: double.infinity, // Rowと同じ幅にする
                ),
              ),

              SizedBox(height: 10),

              // メインコンテンツ
              Container(
                width: double.infinity,
                // height: 60,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),

                // 内部コンテンツ
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 13.0, vertical: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '保存日時：${_formatDate(usageData['usage_date'])}',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF737374)),
                                ),
                                Text(
                                  '比較台数：${usageData['usage_count'] ?? '0'}台',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: (usageData['usage_count'] ?? 0) > 0
                                  ? () {
                                      final commonState =
                                          context.findAncestorStateOfType<
                                              CommonScreenState>();
                                      commonState?.onItemTapped(2); // 使用タブに遷移
                                    }
                                  : null,

// usage_countが0以下の場合は押せない
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (usageData['usage_count'] ?? 0) > 0
                                        ? const Color(0xFF4A14CA)
                                        : Colors.grey, // 押せないときはグレー
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                '続ける',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 履歴と点線の幅調節
                    SizedBox(
                      height: 10,
                    ),

                    // 点線のボーダーを追加
                    CustomPaint(
                      painter: DashedLinePainter(
                          color: Color(0xFFD0D0D0)), // カスタムペインターで点線を描画
                      child: Container(
                        height: 1,
                        width: double.infinity, // Rowと同じ幅にする
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: 30,
          ),

          // おすすめ商品
          Column(
            children: [
              // ユーザー情報ヘッダー
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 子要素を左右に均等に配置
                children: [
                  Text(
                    'おすすめ・新着商品',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffffff)),
                  ),

                  // 詳細ボタン
                  // リンク機能付与
                  GestureDetector(
                    onTap: () {
                      // CommonScreenState にアクセスして index を更新
                      final commonState =
                          context.findAncestorStateOfType<CommonScreenState>();
                      commonState?.onItemTapped(1); // 4はマイページのインデックス
                    },
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 子ウィジェットを上揃え
                      children: [
                        Text(
                          '詳細',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFffffff)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // 矢印
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0), // 上から3pxの余白を追加して下にずらす
                          child: Image.asset(
                            'assets/home/detail-button.png',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              // 点線との幅
              SizedBox(
                height: 6,
              ),

              // 点線のボーダーを追加
              CustomPaint(
                painter:
                    DashedLinePainter(color: Colors.white), // カスタムペインターで点線を描画
                child: Container(
                  height: 1,
                  width: double.infinity, // Rowと同じ幅にする
                ),
              ),

              SizedBox(height: 10),

              // メインコンテンツ（例として空のコンテナ）
              Container(
                width: double.infinity,
                // height: 60,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),

                // 内部コンテンツIMGとtextエリアの横並び
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xffA0A0A0), // ボーダーの色
                              width: 1.0, // ボーダーの太さ
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  // Textを親要素の幅に合わせて折り返す
                                  child: Text(
                                    '${product['name'] ?? '商品名の取得に失敗しました。'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0,
                                  ),
                                  child: Image.asset(
                                    'assets/product/product-detail.png',
                                    width: 19,
                                    height: 19,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  'メーカー：${product['manufacturer'] ?? 'なし'}',
                                  style: TextStyle(
                                    color: Color(0xFF673AD3),
                                    fontSize: 10,
                                  ),
                                ), // メーカーはproductTableから参照

                                SizedBox(width: 24),

                                Text(
                                  'ジャンル：${product['category'] ?? 'なし'}',
                                  style: TextStyle(
                                    color: Color(0xFF673AD3),
                                    fontSize: 10,
                                  ),
                                ), // ジャンルはproductTableから参照
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Column(
                          children: [
                            Text(
                              product['description'] != null &&
                                      product['description'].length > 50
                                  ? '${product['description'].substring(0, 50)}...' // 最初の50文字 + "..."
                                  : product['description'] ??
                                      'なし', // 50文字未満の場合またはnullの場合
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 3.0, left: 4),
                                      child: Text(
                                        '￥',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFCF2E2E)),
                                      ),
                                    ),
                                    Text(
                                      '${formatPrice(product['price'])}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Color(0xFFCF2E2E)),
                                    ),
                                  ],
                                ),
                                // ■■■■■■■■　　後程変更（カートに追加システムへ）　　■■■■■■■■
                                Container(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                                  product: Product.fromJson(product)),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4A14CA),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 16),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 2), // ← 下に2pxの余白を入れて上に寄せる
                                          child: Text(
                                            '商品の詳細へ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 30,
          ),

          // お知らせ表示
          Column(
            children: [
              // お知らせヘッダー
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 子要素を左右に均等に配置
                children: [
                  Text(
                    'お知らせ',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffffff)),
                  ),

                  // 詳細ボタン
                  // リンク機能付与
                  GestureDetector(
                    onTap: () {
                      // CommonScreenState にアクセスして index を更新
                      final commonState =
                          context.findAncestorStateOfType<CommonScreenState>();
                      commonState?.onItemTapped(3); // 4はマイページのインデックス
                    },
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 子ウィジェットを上揃え
                      children: [
                        Text(
                          '詳細',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFffffff)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // 矢印
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0), // 上から3pxの余白を追加して下にずらす
                          child: Image.asset(
                            'assets/home/detail-button.png',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              // 点線との幅
              SizedBox(
                height: 6,
              ),

              // 点線のボーダーを追加
              CustomPaint(
                painter:
                    DashedLinePainter(color: Colors.white), // カスタムペインターで点線を描画
                child: Container(
                  height: 1,
                  width: double.infinity, // Rowと同じ幅にする
                ),
              ),

              SizedBox(height: 10),

              // メインコンテンツ（例として空のコンテナ）
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  // color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),

                // 内部コンテンツIMGとtextエリアの横並び
                child: Column(
                  children: newsData
                      .asMap()
                      .entries
                      .map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> newsItem = entry.value;

                        // タグ名を取得（複数タグがある場合に備えて最初のものを使用）
                        String tagName = (newsItem['tags'] != null &&
                                newsItem['tags'].isNotEmpty)
                            ? newsItem['tags'][0]['name']
                            : '未分類';

                        // タイトル
                        String title = newsItem['title'] ?? 'タイトル未設定';

                        // 上部余白（2件目以降にのみ追加）
                        EdgeInsetsGeometry padding = index > 0
                            ? EdgeInsets.only(top: 10, bottom: 10)
                            : EdgeInsets.only(bottom: 10);

                        return Container(
                          padding: padding,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF252525), // ボーダーの色
                                width: 1.0, // ボーダーの太さ
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailScreen(
                                      newsData: newsItem), // データを渡す
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // タグ
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        tagName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A14CA),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // タイトル
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                // 右側のアイコン
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Image.asset(
                                    'assets/news/small-detail.png',
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .take(3)
                      .toList(), // 最大3件まで表示
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
    // home: HomeScreen(),
    ));
