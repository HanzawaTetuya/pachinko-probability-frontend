import 'package:flutter/material.dart';
import 'package:system_alpha/models/product.dart'; // Productモデルをインポート
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/product/product_detail_screen.dart';
import 'cart_screen.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート

class ProductScreen extends StatefulWidget {
  final List<Product> products; // 商品リストを受け取る

  const ProductScreen({Key? key, required this.products}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _cartItemCount = 0; // カートに追加されたアイテム数
  final Map<int, bool> _isAddedToCartMap = {}; // カート追加済みフラグ

  @override
  void initState() {
    super.initState();
    _checkCartStates(); // 各商品のカート状態を確認
  }

  Future<void> _checkCartStates() async {
    for (final product in widget.products) {
      final productNumber = product.productNumber;
      try {
        final isInCart = await ApiService().checkCart(productNumber);
        setState(() {
          _isAddedToCartMap[productNumber] = isInCart;
        });
      } catch (e) {
        print('エラー: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // ← これで右寄せ！
            children: [
              // Container(
              //   padding: EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Color(0xFF815BDA),
              //     shape: BoxShape.circle,
              //   ),
              //   child: Image.asset(
              //     'assets/search.png',
              //     width: 21,
              //     height: 21,
              //   ),
              // ),
              // SizedBox(width: 8),
              // Expanded(
              //   child: TextField(
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //     ),
              //     decoration: InputDecoration(
              //       hintText: '商品を検索',
              //       hintStyle: TextStyle(color: Colors.grey),
              //     ),
              //   ),
              // ),
              Stack(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/product/cart.png',
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen()),
                      );
                    },
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFFCF2E2E),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_cartItemCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // 商品リストを表示
          Expanded(
            child: ListView.builder(
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                final productNumber = product.productNumber;
                final formattedPrice =
                    NumberFormat('#,###').format(product.price); // 数値をフォーマット

                return buildProductInfoCard(
                  title: product.name,
                  manufacturer: product.manufacturer,
                  genre: product.category,
                  description: product.description.length > 50
                      ? '${product.description.substring(0, 50)}...' // 最初の50文字 + "..."
                      : product.description, // 50文字未満の場合はそのまま表示
                  price: formattedPrice, // フォーマット済みの価格を渡す
                  isAddedToCart: _isAddedToCartMap[productNumber] ?? false,
                  onAddToCart: () async {
                    final status = await ApiService().addToCart(productNumber);

                    switch (status) {
                      case 'added_to_cart':
                        setState(() {
                          _isAddedToCartMap[productNumber] = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('カートに商品を追加しました。'),
                            backgroundColor: Color(0xFF4A14CA),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        break;

                      case 'already_in_cart':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('この商品は既にカートに追加されています。カート画面に移動します。'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        );
                        break;

                      case 'already_purchased':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('この商品は既に購入済みです。'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        break;

                      case 'error':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('エラーが発生しました。再度お試しください。'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        break;

                      default:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('不明なエラーが発生しました。'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        break;
                    }
                  },
                  onDetailTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: product), // 詳細画面に商品を渡す
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}

// 商品情報カードを表示するメソッド
Widget buildProductInfoCard({
  required String title,
  required String manufacturer,
  required String genre,
  required String description,
  required String price,
  required bool isAddedToCart,
  required VoidCallback onAddToCart,
  required VoidCallback onDetailTap,
}) {
  return Column(
    children: [
      SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                      onTap: onDetailTap,
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
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(description),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, left: 4),
                            child: Text(
                              '￥',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCF2E2E),
                              ),
                            ),
                          ),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFFCF2E2E),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4), // ← ボタンを下にずらす
                        child: ElevatedButton(
                          onPressed: isAddedToCart ? null : onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isAddedToCart ? Colors.grey : Color(0xFF4A14CA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 7),
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  isAddedToCart ? 'カートに追加済み' : 'カートに追加',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
