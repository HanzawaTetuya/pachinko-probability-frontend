import 'package:flutter/material.dart';
import 'package:system_alpha/mypage/order/item_detail_screen.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート

class OrderDetailScreen extends StatefulWidget {
  final String orderNumber;
  final Map<String, dynamic> orderDetails; // APIから受信した注文詳細

  const OrderDetailScreen({
    Key? key,
    required this.orderNumber,
    required this.orderDetails,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();

    print("orderDetails の data 部分: ${widget.orderDetails['data']}");

    widget.orderDetails.forEach((key, value) {
      print("$key: $value");
    });

    // デバッグ用: 製品リストがある場合、各製品を出力
    if (widget.orderDetails.containsKey('products')) {
      final products = widget.orderDetails['products'] as List<dynamic>;
      for (var product in products) {
        print("製品データ:");
        product.forEach((key, value) {
          print("  $key: $value");
        });
      }
    }
  }

// 日付フォーマット関数
  String _formatDate(String? isoDate) {
    if (isoDate == null) return '不明';
    try {
      // ISO形式の日付文字列を DateTime に変換
      final dateTime = DateTime.parse(isoDate);
      // 希望の形式にフォーマット
      final formatter = DateFormat('yyyy年MM月dd日');
      return formatter.format(dateTime);
    } catch (e) {
      return '不明'; // 解析エラーの場合
    }
  }

  // 金額フォーマット関数
  String _formatPrice(dynamic price) {
    if (price == null) return '不明';
    try {
      // 文字列の場合は double に変換
      final double priceValue = double.parse(price.toString());
      // 金額をカンマ区切りの形式にフォーマット
      final formatter = NumberFormat('#,###');
      return '${formatter.format(priceValue)}';
    } catch (e) {
      return '不明'; // 解析エラーの場合
    }
  }

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
  // 支払管理とログアウトボタンを表示するメソッド

  @override
  Widget build(BuildContext context) {
    final products = widget.orderDetails['data']['products'] as List<dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(), // ← のびるスクロール感
          padding: EdgeInsets.only(bottom: 16), // ← 最下部余白の追加（併用OK）
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildHeader("注文詳細"),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    // ← 中はそのままでOK
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '購入情報',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('注文番号: ${widget.orderNumber}'),
                      SizedBox(height: 5),
                      Text(_formatDate(
                          widget.orderDetails['data']['created_at'])),
                      SizedBox(height: 12),
                      Text('購入商品：'),
                      SizedBox(height: 10),
                      Column(
                        children: products.map((product) {
                          return buildProductDetailCard(
                            context: context,
                            title: product['name'],
                            manufacturer: product['manufacturer'],
                            genre: product['category'],
                            price: _formatPrice(product['price']),
                            description: product['description'] != null &&
                                    product['description'].length > 50
                                ? '${product['description'].substring(0, 50)}...'
                                : product['description'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(
                                    productDetails: product,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text('合計金額'),
                            ),
                            SizedBox(width: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    '￥',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  _formatPrice(widget.orderDetails['data']
                                      ['total_price']),
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProductDetailCard({
    required BuildContext context,
    required String title,
    required String manufacturer,
    required String genre,
    required String price,
    required String description,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        SizedBox(height: 16), // 上部のスペース
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFFD0D0D0),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xffA0A0A0),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Image.asset(
                              'assets/product/product-detail.png',
                              width: 19,
                              height: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'メーカー：$manufacturer',
                          style: TextStyle(
                            color: Color(0xFF673AD3),
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 24),
                        Text(
                          'ジャンル：$genre',
                          style: TextStyle(
                            color: Color(0xFF673AD3),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                  child: Text(
                description,
                style: TextStyle(fontSize: 12),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
