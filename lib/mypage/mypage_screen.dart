import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_alpha/auth/login.dart';
import 'package:system_alpha/mypage/favorite/favorite_list_screen.dart';
import 'package:system_alpha/mypage/order/order_history_screen.dart';
import 'package:system_alpha/mypage/support/support_screen.dart';
import 'package:system_alpha/mypage/userinfo_screen.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/terms/terms_screen.dart';
import '../auth/login.dart';
import 'package:system_alpha/terms/privacy_screen.dart';

class MyPageScreen extends StatefulWidget {
  final ApiService apiService = ApiService();

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? sharedPrefData;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefData();
    debugPrintSharedPreferences(); // デバッグ用にすべてのSharedPreferencesをコンソールに表示
  }

  Future<void> _loadSharedPrefData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sharedPrefData = prefs.getString('access_token') ?? 'No data found';
    });
  }

  Future<void> debugPrintSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (String key in keys) {
      final value = prefs.get(key);
      print('Key: $key, Value: $value'); // すべてのキーと値をコンソールに出力
    }
  }

  void _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ログアウトしますか？'),
          content: Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('ログアウト'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // ローディング表示（非キャンセル）
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      // ここで2秒待つ（トークン削除前でもOK）
      await Future.delayed(Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      // ローディング閉じる
      Navigator.of(context).pop();

      // LoginPage に遷移（ログアウト通知付き）
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(loginMessage: 'ログアウトしました'),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Column(
        children: [
          // 会員情報
          _buildCardItem(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserinfoScreen()), // DetailScreenに遷移
              );
            },
            imagePath: 'assets/mypage/mypage-user.png',
            title: '会員情報',
          ),
          SizedBox(height: 14),
          // 購入履歴 & お気に入りリスト
          Row(
            children: [
              Expanded(
                child: _buildCardItem(
                  onTap: () async {
                    try {
                      // ApiServiceのorderIndexメソッドを使用して購入履歴を取得
                      // ApiServiceのorderIndexメソッドを使用して購入履歴を取得
                      final orderHistory = await widget.apiService.orderIndex();

                      // デバッグ用に取得したデータの型と値を表示
                      for (var order in orderHistory) {
                        print(
                            "order_number の型: ${order['order_number'].runtimeType}, 値: ${order['order_number']}");
                        print(
                            "total_price の型: ${order['total_price'].runtimeType}, 値: ${order['total_price']}");
                        print(
                            "created_at の型: ${order['created_at'].runtimeType}, 値: ${order['created_at']}");
                      }

                      // 必要なデータのみ抽出
                      final filteredOrderHistory = orderHistory.map((order) {
                        return {
                          "order_number":
                              order['order_number'], // 型を確認後、適切なキーを設定
                          "total_price": order['total_price'],
                          "created_at": order['created_at'],
                        };
                      }).toList();

                      // 次の画面に遷移しつつデータを渡す
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderHistoryScreen(
                            orderHistory: filteredOrderHistory,
                          ),
                        ),
                      );
                    } catch (e) {
                      // エラー時の処理
                      print("購入履歴取得中にエラーが発生しました: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("購入履歴を取得できませんでした: $e")),
                      );
                    }
                  },
                  imagePath: 'assets/mypage/mypage-cart.png',
                  title: '購入履歴',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _buildCardItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavoriteListScreen()),
                    );
                  },
                  imagePath: 'assets/mypage/mypage-favorite.png',
                  title: 'お気に入りリスト',
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          // 通知設定 & サポート・ヘルプ
          Row(
            children: [
              // Expanded(
              //   child: _buildCardItem(
              //     onTap: () {
              //       // 推移先
              //     },
              //     imagePath: 'assets/mypage/mypage-notification.png',
              //     title: '通知設定',
              //   ),
              // ),
              // SizedBox(width: 14),
              Expanded(
                child: _buildCardItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportScreen()),
                    );
                  },
                  imagePath: 'assets/mypage/mypage-support.png',
                  title: 'サポート・ヘルプ',
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // リスト項目 (利用規約、プライバシーポリシー、ガイドライン、ログアウト)
          Container(
            width: double.infinity,
            child: Column(
              children: [
                _buildListItem(
                  title: '利用規約',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsScreen()),
                    );
                  },
                ),
                _buildListItem(
                  title: 'プライバシーポリシー',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyScreen()),
                    );
                  },
                ),
                _buildListItem(
                  title: 'ログアウト',
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 共通のリスト項目を作成するメソッド
  Widget _buildListItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xff252525),
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 共通のカード項目を作成するメソッド
  Widget _buildCardItem({
    required VoidCallback onTap,
    required String imagePath,
    required String title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
