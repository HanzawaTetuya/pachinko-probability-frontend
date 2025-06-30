import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productDetails; // 商品詳細データを受け取る

  const ItemDetailScreen({
    Key? key,
    required this.productDetails,
  }) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
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

  @override
  Widget build(BuildContext context) {
    final product = widget.productDetails; // 渡された商品詳細データ

    return Scaffold(
      backgroundColor: const Color(0xFF01020C),

      // メインコンテンツ
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("購入品詳細"),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 32,
                bottom: 32,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xffA0A0A0),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? '不明な商品名',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              'メーカー：${product['manufacturer'] ?? '不明'}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6437D0),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'ジャンル：${product['category'] ?? '不明'}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6437D0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '発売日：2024年12月1日', // 必要に応じて動的に表示可能
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    product['description'] ??
                        '説明がありません', // 説明を50文字以内に切り詰めたい場合に編集
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
