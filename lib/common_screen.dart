import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'product/product_screen.dart';
import 'system/system_screen.dart';
import 'news/news_screen.dart';
import 'mypage/mypage_screen.dart';
import 'package:system_alpha/api/api_service.dart';
import '../models/product.dart';

class CommonScreen extends StatefulWidget {
  final int initialIndex;
  final String? loginMessage;

  // ↓↓↓ 関数型のコールバックを追加
  final Function(BuildContext context)? onSystemTabOpened;

  const CommonScreen({
    this.initialIndex = 0,
    this.loginMessage,
    this.onSystemTabOpened,
    Key? key,
  }) : super(key: key);

  @override
  CommonScreenState createState() => CommonScreenState();
}

class CommonScreenState extends State<CommonScreen> {
  int _selectedIndex = 0;

  // 各タブのNavigatorキーを管理するリスト
  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    if (widget.loginMessage != null) {
      print("loginMessage: ${widget.loginMessage}");
    }
    _selectedIndex = widget.initialIndex; // ←これが初期選択を制御
  }

  void onItemTapped(int index) async {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      if (index == 2) {
        // SystemScreenが選択された場合
        try {
          final response = await ApiService().getOrderAll(); // データ取得

          // result_usageを抽出
          final resultUsage = response['result_usage'] ?? {}; // nullなら空のマップを設定

          // 'data'部分のみ抽出して渡す
          final orders = response['data'];
          _navigatorKeys[index].currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SystemScreen(
                    orders: orders,
                    resultUsage: resultUsage, // result_usageを渡す
                  ),
                ),
              );
        } catch (e) {
          print("エラー: $e"); // エラー処理
        }
      }

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[index].currentState!.maybePop();
          return isFirstRouteInCurrentTab;
        },
        child: Navigator(
          key: _navigatorKeys[index],
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
              builder: (context) => _getScreenForIndex(index),
            );
          },
        ),
      ),
    );
  }

  // 各タブの初期ページを取得するメソッド
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return FutureBuilder<Map<String, dynamic>>(
          future: ApiService().homeData(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // ローディングスピナーを表示
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // エラー時の表示
              return Center(child: Text('エラー: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // データが取得できた場合
              final data = snapshot.data!;
              final userInfo = data['userInfo'] as Map<String, dynamic>;
              final usageData = data['usageData'] as Map<String, dynamic>;
              final product = data['product'] as Map<String, dynamic>;
              final newsData = data['newsData'] as List<dynamic>; // newsDataを追加

              // ホーム画面にデータを渡す
              return HomeScreen(
                userInfo: userInfo,
                usageData: usageData,
                product: product,
                newsData: newsData, // newsDataを渡す
              );
            } else {
              // データが空の場合
              return Center(child: Text('データがありません'));
            }
          },
        );

      case 1:
        return FutureBuilder<List<Product>>(
          future: ApiService().fetchProducts(), // fetchProductsを呼び出す
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // データ取得中はローディングを表示
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // エラーの内容を表示
              return Center(child: Text('エラー'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // データが空の場合
              return Center(child: Text('商品データがありません'));
            }

            // データ取得成功時、ProductScreenにデータを渡す
            return ProductScreen(products: snapshot.data!);
          },
        );
      case 2:
        return SystemScreen();
      case 3:
        return NewsScreen();
      case 4:
        return MyPageScreen();
      default:
        return FutureBuilder<Map<String, dynamic>>(
          future: ApiService().homeData(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // ローディングスピナーを表示
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // エラー時の表示
              return Center(child: Text('エラー: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // データが取得できた場合
              final data = snapshot.data!;
              final userInfo = data['userInfo'] as Map<String, dynamic>;
              final usageData = data['usageData'] as Map<String, dynamic>;
              final product = data['product'] as Map<String, dynamic>;
              final newsData = data['newsData'] as List<dynamic>; // newsDataを追加

              // ホーム画面にデータを渡す
              return HomeScreen(
                userInfo: userInfo,
                usageData: usageData,
                product: product,
                newsData: newsData, // newsDataを渡す
              );
            } else {
              // データが空の場合
              return Center(child: Text('データがありません'));
            }
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01020C),
        centerTitle: true,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Image.asset(
            'assets/main-logo.png',
            width: 130,
            height: 30,
          ),
        ),
        toolbarHeight: 116.0,
      ),
      body: Stack(
        children: List.generate(5, (index) => _buildOffstageNavigator(index)),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomAppBar(
          color: const Color(0xFF1A1B24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildIconWithLabel('assets/footer/home-icon.png', 'ホーム', 0),
              _buildIconWithLabel('assets/footer/product-icon.png', '製品購入', 1),
              _buildIconWithLabel('assets/footer/use-icon.png', '使用', 2),
              _buildIconWithLabel('assets/footer/news-icon.png', 'お知らせ', 3),
              _buildIconWithLabel('assets/footer/mypage-icon.png', 'マイページ', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithLabel(String assetPath, String label, int index) {
    bool isSelected = _selectedIndex == index;

    String modifiedAssetPath =
        isSelected ? assetPath.replaceAll('.png', '-top.png') : assetPath;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              modifiedAssetPath,
              width: 23,
              height: 23,
            ),
            const SizedBox(height: 5),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Color(0xFFE6E6E7) : Color(0xFF737374),
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
