import 'package:flutter/material.dart';
import 'package:system_alpha/models/product.dart'; // Productモデルをインポート
import 'package:system_alpha/api/api_service.dart';
import 'cart_screen.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート
import 'package:system_alpha/constants/term_notice.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product; // 商品データを受け取る

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  bool _isAddedToCart = false; // カート追加済みの状態を管理
  bool _isLoading = true; // 初期ロード中フラグ

  @override
  void initState() {
    super.initState();
    _checkInitialStates(); // 初期状態のチェック
  }

  Future<void> _checkInitialStates() async {
    final productNumber = widget.product.productNumber;

    try {
      final isFavorite = await ApiService().isFavorite(productNumber);
      final isInCart = await ApiService().checkCart(productNumber);

      setState(() {
        _isFavorite = isFavorite;
        _isAddedToCart = isInCart;
        _isLoading = false; // 状態の確認が終わったらロードを解除
      });
    } catch (e) {
      print('エラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ロード中の表示
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF01020C),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 価格をカンマ区切りでフォーマット
    final formattedPrice = NumberFormat('#,###').format(widget.product.price);

    // 発売日を日付だけにフォーマット
    String formattedReleaseDate;
    try {
      final parsedDate = DateTime.parse(widget.product.releaseDate);
      formattedReleaseDate = DateFormat('yyyy年MM月dd日').format(parsedDate);
    } catch (e) {
      formattedReleaseDate = '不明'; // 日付が解析できなかった場合のフォールバック
    }

    return Scaffold(
        backgroundColor: const Color(0xFF01020C),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(), // ← のびるスクロール感
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // 戻るボタン
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
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Image.asset(
                          _isFavorite
                              ? 'assets/favorite.png'
                              : 'assets/not-favorite.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // 商品詳細カード
                buildProductDetailCard(
                  title: widget.product.name, // 商品名
                  manufacturer: widget.product.manufacturer, // メーカー名
                  genre: widget.product.category, // カテゴリー
                  releaseDate: formattedReleaseDate, // フォーマット済みの発売日
                  price: formattedPrice, // フォーマット済みの価格
                  description: widget.product.description, // 商品説明
                  isAddedToCart: _isAddedToCart,
                  onAddToCart: _addToCart, // 修正: ボタン押下時の処理
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  Future<void> _toggleFavorite() async {
    final productNumber = widget.product.productNumber;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      bool success;
      if (_isFavorite) {
        success = await ApiService().removeFavorite(productNumber);
      } else {
        success = await ApiService().addFavorite(productNumber);
      }

      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'お気に入りに登録しました。' : 'お気に入りから削除しました。',
            ),
            backgroundColor: Color(0xFF4A14CA),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('お気に入りの操作に失敗しました。再度お試しください。'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    final productNumber = widget.product.productNumber;

    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final status = await ApiService().addToCart(productNumber);

      Navigator.of(context, rootNavigator: true).pop();

      switch (status) {
        case 'added_to_cart':
          setState(() {
            _isAddedToCart = true;
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
              backgroundColor: Colors.orange,
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
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget buildProductDetailCard({
    required String title, // 商品名
    required String manufacturer, // メーカー名
    required String genre, // ジャンル
    required String releaseDate, // 発売日
    required String price, // フォーマット済みの価格
    required String description, // 商品説明
    required VoidCallback onAddToCart, // カートに追加するためのコールバック
    bool isAddedToCart = false, // カート追加済みフラグ（デフォルトはfalse）
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 商品情報部分
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
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'メーカー：$manufacturer',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6437D0),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'ジャンル：$genre',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6437D0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '発売日：$releaseDate',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // 価格とカート追加ボタン部分
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 7.0, left: 4),
                    child: Text(
                      '￥',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: isAddedToCart ? Colors.grey : Color(0xFF4A14CA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: isAddedToCart ? null : onAddToCart,
                  child: isAddedToCart
                      ? Text(
                          'カートに追加済み',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'カートに追加',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),

          // 商品説明部分
          Text(
            description,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 10),

          // 注意事項
          Text(
            productNotice,
            style: TextStyle(
              color: Color(0xFF737374),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
