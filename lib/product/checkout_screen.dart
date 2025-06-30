import 'package:flutter/material.dart';
import '/home_screen.dart';
import 'product_detail_screen.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:intl/intl.dart'; // intlパッケージをインポート

class CheckoutScreen extends StatefulWidget {
  final String orderNumber;

  const CheckoutScreen({
    Key? key,
    required this.orderNumber,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'none';
  String _orderNumber = ''; // 注文番号を格納
  String _totalPrice = ''; // 合計金額を格納
  List<String> _productNames = []; // 購入商品名を格納

  @override
  void initState() {
    super.initState();
    print("注文番号: ${widget.orderNumber}");
    fetchOrderDetails(); // 注文情報を取得
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderDetails =
          await ApiService().getOrder(widget.orderNumber); // API から注文情報を取得
      print("注文情報: $orderDetails");

      if (orderDetails != null) {
        setState(() {
          _orderNumber = (orderDetails['order_number'] as List<dynamic>)
              .first
              .toString(); // 注文番号をセット
          _totalPrice =
              orderDetails['total_price']?.toString() ?? '0'; // 合計金額をセット
          _productNames = List<String>.from(orderDetails['products']
                  ?.map((product) => product['product_name']) ??
              []); // 商品名リストをセット
        });
      } else {
        print("注文情報が見つかりません。");
      }
    } catch (e) {
      print("注文情報の取得中にエラーが発生しました: $e");
    }
  }

  // 金額をフォーマットする関数
  String formatPrice(String price) {
    final formatter = NumberFormat("#,##0", "ja_JP");
    final intPrice = int.tryParse(price) ?? 0;
    return formatter.format(intPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
// メインコンテンツ
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // backbuttonとfavoritebutton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側の戻るボタン（画像）
                GestureDetector(
                  onTap: () {
                    // Navigator.push(

                    // );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, // 背景色
                      borderRadius: BorderRadius.circular(5), // 角丸
                    ),
                    child: Image.asset(
                      'assets/home-back.png', // 戻るボタンの画像パス
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //
            // thanksCard
            //
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white, // 背景色
                borderRadius: BorderRadius.circular(10), // 角丸
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ご購入ありがとうございます。',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'ご購入後すぐにお使いいただけます。',
                    style: TextStyle(fontSize: 12, color: Color(0xFF01020C)),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(0xFF4A14CA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => PaymentMethodScreen()),
                        // );
                      },
                      child: Text(
                        '今すぐ使用する',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 14,
            ),
            //
            // 購入情報
            //
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 21),
              decoration: BoxDecoration(
                color: Colors.white, // 背景色
                borderRadius: BorderRadius.circular(10), // 角丸
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

                  SizedBox(
                    height: 16,
                  ),

                  // 商品の詳細
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 注文番号
                        Container(
                          child: Row(
                            children: [
                              Text(
                                '注文番号：',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _orderNumber.isNotEmpty
                                    ? _orderNumber
                                    : '注文番号がありません',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '購入商品：',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              // 購入商品リストを動的に表示
                              ..._productNames.map((productName) => Text(
                                    '・$productName',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '合計金額：￥${formatPrice(_totalPrice)}', // フォーマットした金額を表示
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'おすすめ商品',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // お勧め商品を３つ表示
                        Container(
                          width: double.infinity,
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
                                      // GestureDetectorを挿入
                                      GestureDetector(
                                        onTap: () {
                                          // Navigator.push(

                                          // );
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              // Textを親要素の幅に合わせて折り返す
                                              child: Text(
                                                '(サンプル)P新世紀エヴァンゲリオン〜未来への咆哮〜SPECIAL EDITION',
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
                                      ),

                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            'メーカー：ビスティ',
                                            style: TextStyle(
                                              color: Color(0xFF673AD3),
                                              fontSize: 10,
                                            ),
                                          ), // メーカーはproductTableから参照

                                          SizedBox(width: 24),

                                          Text(
                                            'ジャンル：アニメ',
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
                                          '人気の「新世紀エヴァンゲリオン〜未来への咆哮〜」にライトミドルタイプが登場！スペックは高継続率のV...'),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 3.0, left: 4),
                                                child: Text(
                                                  '￥',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFCF2E2E)),
                                                ),
                                              ),
                                              Text(
                                                '33,000',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: Color(0xFFCF2E2E)),
                                              ),
                                            ],
                                          ),
                                          // ElevatedButtonを外側のRowの子要素として追加
                                          Container(
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                    0xFF4A14CA), // ボタンの背景色
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5), // 角を丸くする
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
                                                    'カートに追加',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFffffff),
                                                    ),
                                                  ),
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
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required String value,
    Color? selectedColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value ? selectedColor : Colors.white,
          border: Border.all(
            color: Color(0xFFC7C7C7),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              activeColor: Color(0xFF4A14CA),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'クレジットカード名義人',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'カード番号',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '有効期限 (月)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: List.generate(12, (index) {
                  final month = (index + 1).toString().padLeft(2, '0');
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }),
                onChanged: (value) {},
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '有効期限 (年)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: List.generate(10, (index) {
                  final year = (DateTime.now().year + index).toString();
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextField(
          style: TextStyle(color: Color(0xFFC7C7C7)),
          decoration: InputDecoration(
            labelText: 'セキュリティコード (CVV)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // カードを追加する処理
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A14CA),
              minimumSize: Size(double.infinity, 44), // 高さを44に設定
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 角丸を10に設定
              ),
            ),
            child: Text(
              'カードを追加',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
