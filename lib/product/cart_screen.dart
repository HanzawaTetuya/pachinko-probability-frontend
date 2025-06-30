import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/product/checkout_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = []; // カート内の商品リスト
  bool _isLoading = true; // ローディングフラグ
  Map<String, bool> _deletingFlags = {}; // 商品ごとの削除フラグ

  double _totalAmount = 0.0;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // カートアイテムを取得
  }

  Future<void> _fetchCartItems() async {
    try {
      final cartItems = await apiService.getCarts();
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
        _totalAmount = _cartItems.fold(
          0.0,
          (sum, item) => sum + (item['price'] as double),
        ); // 合計金額を計算
      });
    } catch (e) {
      print('カート情報の取得中にエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 金額をフォーマットする関数
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'ja_JP', symbol: '￥');
    return formatter.format(amount);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログ閉じる
              },
            ),
          ],
        );
      },
    );
  }

  // URL転送確認のためのコード
  Future<void> _handlePayment() async {
    print('[_handlePayment] 開始');

    final apiService = ApiService();
    try {
      html.WindowBase? newWindow;

      if (kIsWeb) {
        newWindow = html.window.open('', '_blank');
        if (newWindow == null) {
          print('[_handlePayment] 仮ウィンドウを開けませんでした（ポップアップブロック）');
          _showErrorDialog("ブラウザ設定によりリンクを開けませんでした。ポップアップブロックを解除してください。");
          return;
        }
        print('[_handlePayment] 仮ウィンドウをオープン成功');
      }

      final paymentUrl = await apiService.startPurchase();

      if (paymentUrl == null) {
        print('[_handlePayment] paymentUrlがnullです');
        _showErrorDialog("決済リンクが取得できませんでした。ネットワークをご確認ください。");
        return;
      }

      print('[_handlePayment] 取得したpaymentUrl: $paymentUrl');

      if (kIsWeb) {
        newWindow!.location.href = paymentUrl;
        print('[_handlePayment] 仮ウィンドウにURLをセットしました');
      } else {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          print('[_handlePayment] launchUrl成功');
        } else {
          _showErrorDialog("リンクを開けませんでした。ブラウザ設定をご確認ください。");
        }
      }
    } catch (e) {
      print('[_handlePayment] エラー発生: $e');
      _showErrorDialog("予期せぬエラーが発生しました。もう一度お試しください。");
    }
  }

  Widget _buildCartItem(dynamic item) {
    final productNumber =
        item['product_number'].toString(); // ← ここで必ず String に変換

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xffD0D0D0), width: 1.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'メーカー：${item['manufacturer'] ?? ''}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6437D0),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'ジャンル：${item['category'] ?? ''}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6437D0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      '￥',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF01020C),
                      ),
                    ),
                  ),
                  Text(
                    '${NumberFormat("#,###").format(item['price'] ?? 0)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF01020C),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _deletingFlags[productNumber] == true
                    ? null
                    : () async {
                        print('🟢 削除処理開始: productNumber = $productNumber');

                        setState(() {
                          _deletingFlags[productNumber] = true;
                        });

                        final success =
                            await apiService.removeCarts(productNumber);
                        print('🟡 削除リクエスト結果: $success');

                        if (success) {
                          await _fetchCartItems(); // ← カート再取得で小計も再計算される

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${item['name']} をカートから削除しました。')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('商品の削除に失敗しました。')),
                          );
                        }

                        setState(() {
                          _deletingFlags[productNumber] = false;
                        });
                        print('🔚 削除処理完了: フラグ解除');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA0A0A0),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: _deletingFlags[productNumber] == true
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Row(
                        children: [
                          Icon(Icons.delete, size: 14, color: Colors.white),
                          SizedBox(width: 7),
                          Text(
                            '削除',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF01020C),
        body: Container(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(), // ← ふわっと伸びるスクロール感
            padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 40),
            child: Column(
              children: [
                Row(
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
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Text(
                              '小計',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 6.0, left: 4),
                                child: Text(
                                  '￥',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${NumberFormat("#,###").format(_totalAmount.toInt())}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'ご購入後すぐにお使いいただけます。',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF737374)),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _cartItems.isEmpty
                              ? Colors.grey
                              : Color(0xFF4A14CA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: _cartItems.isEmpty ? null : _handlePayment,
                          child: Text(
                            'お会計に進む',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // Expanded消してそのままchildにする！
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _cartItems.isEmpty
                        ? Center(
                            child: Text(
                              'カートは空です。',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Column(
                            // ← ListView.builderじゃなくColumnに変えよう！
                            children: _cartItems
                                .map((item) => _buildCartItem(item))
                                .toList(),
                          )
              ],
            ),
          ),
        ));
  }
}
