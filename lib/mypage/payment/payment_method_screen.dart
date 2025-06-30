import 'package:flutter/material.dart';
// import 'package:system_alpha/mypage/payment/add_payment_method_screen.dart';
import 'package:system_alpha/mypage/payment/edit_payment_method_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<PaymentMethodScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),

      // メインコンテンツ
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("支払方法"),
            SizedBox(height: 40),
            Container(
              padding:
                  EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white, // 内側のContainerにのみ背景色を適用
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // ヘッダー
                    children: [
                      Text(
                        '登録済み支払方法',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           AddPaymentMethodScreen()),
                            // );
                          },
                          child: Text(
                            '＋追加',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF673AD3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  buildPaymentMethodRow(
                      title: 'クレジットカード', // 登録支払方法名
                      maskedNumber: '****0000', // クレジット番号下４桁
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditPaymentMethodScreen()),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
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
              color: Color(0xffE3E3E3), // ボーダーの色
              width: 1.0, // ボーダーの太さ
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
                  Text(
                    maskedNumber,
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
