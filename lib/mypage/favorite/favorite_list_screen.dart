import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/models/product.dart';
import '/../product/product_detail_screen.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート
import 'package:system_alpha/product/cart_screen.dart';

class FavoriteListScreen extends StatefulWidget {
  @override
  _FavoriteListScreenState createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  List<dynamic> _favorites = [];
  bool _isLoading = true;

  final Map<int, bool> _isAddedToCartMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchFavorites();
    await _checkCartStates();
  }

  Future<void> _checkCartStates() async {
    for (final product in _favorites) {
      final productNumber = product['product_number'];
      try {
        final isInCart = await ApiService().checkCart(productNumber);
        setState(() {
          _isAddedToCartMap[productNumber] = isInCart;
        });
      } catch (e) {
        print('カート確認エラー: $e');
      }
    }
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await ApiService().getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

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
        Container(width: 24, height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("お気に入りリスト"),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _favorites.isEmpty
                    ? Center(
                        child: Text(
                          "お気に入りの商品がありません",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final product = _favorites[index];
                          final formattedPrice =
                              NumberFormat('#,###').format(product['price']);
                          final shortDescription = product['description']
                                      .length >
                                  50
                              ? '${product['description'].substring(0, 50)}...'
                              : product['description'];

                          return buildProductInfoCard(
                            title: product['name'],
                            manufacturer: product['manufacturer'],
                            genre: product['category'],
                            description: shortDescription,
                            price: formattedPrice,
                            isAddedToCart:
                                _isAddedToCartMap[product['product_number']] ??
                                    false,
                            onAddToCart: () async {
                              final productNumber = product['product_number'];

                              final status =
                                  await ApiService().addToCart(productNumber);

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
                                      content: Text(
                                          'この商品は既にカートに追加されています。カート画面に移動します。'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CartScreen()),
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
                                  builder: (context) => ProductDetailScreen(
                                    product: Product.fromJson(product),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    double topPadding = 20.0,
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding),
        Container(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A14CA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                Column(
                  children: [
                    Text(description),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 3.0, left: 4),
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
                        Container(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A14CA),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/product/cart.png',
                                  width: 14,
                                  height: 14,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  isAddedToCart ? '追加済み' : 'カートに追加',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFffffff),
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
}
