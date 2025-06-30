import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:system_alpha/mypage/order/order_detail_screen.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  final List<dynamic> orderHistory;
  const OrderHistoryScreen({Key? key, required this.orderHistory})
      : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = false; // ローディング状態を管理する変数

  @override
  void initState() {
    super.initState();

    // 受け取ったデータをログに出力
    print("受け取った注文履歴データ:");
    print(widget.orderHistory);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '不明';
    try {
      // 文字列や数値型に対応してフォーマット
      final double priceValue = double.parse(price.toString());
      final formatter = NumberFormat('#,###');
      return formatter.format(priceValue);
    } catch (e) {
      return '不明'; // 解析エラーの場合
    }
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildHeader("購入履歴"),
                SizedBox(height: 40),
                Container(
                  padding:
                      EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
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
                      ...widget.orderHistory.map((order) {
                        return buildPaymentMethodRow(
                          title: '注文番号：${order['order_number']}', // 注文番号
                          maskedNumber: order['total_price'], // 数値または文字列をそのまま渡す
                          onTap: () async {
                            try {
                              setState(() {
                                _isLoading = true; // ローディング開始
                              });

                              // 注文番号を文字列として取得
                              final String orderNumber =
                                  order['order_number'].toString();
                              print("送信する注文番号: $orderNumber");

                              // APIリクエストのデバッグ
                              print("API送信開始: 注文番号を送信します。");

                              final orderDetails =
                                  await ApiService().orderDetail(orderNumber);

                              // APIレスポンスのデバッグ
                              print("注文詳細データを受信しました: $orderDetails");

                              // 画面遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailScreen(
                                    orderNumber: orderNumber,
                                    orderDetails: orderDetails, // APIの結果を次画面に渡す
                                  ),
                                ),
                              );
                            } catch (e) {
                              // エラー時の処理
                              print("注文詳細取得中にエラーが発生しました: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("注文詳細を取得できませんでした: $e"),
                                ),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false; // ローディング終了
                              });
                            }
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // 背景を半透明に
              child: Center(
                child: CircularProgressIndicator(), // ローディングインジケータ
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPaymentMethodRow({
    required String title,
    required String maskedNumber,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xffE3E3E3),
              width: 1.0,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Color(0xFF01020C), fontSize: 14),
              ),
              Row(
                children: [
                  // フォーマット済みの金額を表示
                  Text(
                    '￥${_formatPrice(maskedNumber)}',
                    style: TextStyle(color: Color(0xFF01020C), fontSize: 14),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, top: 2),
                    child: Image.asset(
                      'assets/user-detail-black.png',
                      width: 7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
