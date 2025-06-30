import 'package:flutter/material.dart';
import 'package:system_alpha/system/system_comparison_screen.dart';
import 'system_input_screen.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:intl/intl.dart';

class SystemScreen extends StatefulWidget {
  final List<dynamic>? orders; // 受け取るデータを追加
  final Map<String, dynamic>? resultUsage; // result_usageを追加

  const SystemScreen({Key? key, this.orders, this.resultUsage})
      : super(key: key);

  @override
  _SystemScreenState createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = false; // ローディング状態を管理

  @override
  @override
  void initState() {
    super.initState();

    if (widget.orders != null) {
      _orders = widget.orders!;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'データがありません';
    try {
      final dateTime = DateTime.parse(isoDate).toLocal(); // ✅ ← ここが追加！
      final formatter = DateFormat('yyyy年MM月dd日');
      return formatter.format(dateTime);
    } catch (e) {
      return 'データがありません';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(// ルートウィジェットを Stack に変更
        children: [
      Container(
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(), // ← のびるスクロール感
              padding: EdgeInsets.only(
                  left: 16, right: 16, top: 20, bottom: 40), // 下にも余白追加
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ここから置き換え
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xffA0A0A0),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            '利用可能な台一覧',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ..._orders.map((order) {
                          return buildPurchaseCard(
                            purchaseDate: order['created_at'] ?? '不明',
                            productName: order['name'] ?? '不明',
                            additionalInfo: '',
                            onUsePressed: () async {
                              setState(() {
                                _isLoading = true; // ローディング開始
                              });

                              try {
                                // API 呼び出し
                                final response =
                                    await ApiService().verifyLicense(
                                  productNumber: order['product_number'],
                                  licenseId: order['license_id'],
                                );

                                // レスポンス確認とデバッグ出力
                                print("API呼び出し成功: レスポンスデータ: $response");

                                if (response['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(response['message'])),
                                  );

                                  // 画面遷移
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SystemInputScreen(
                                        productNumber: order['product_number'],
                                        licenseId: order['license_id'],
                                        productName: order['name'], // 追加: 名前を渡す
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(response['message'] ??
                                            "エラーが発生しました")),
                                  );
                                }
                              } catch (e) {
                                print("API呼び出しエラー: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("APIエラーが発生しました: $e")),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false; // ローディング終了
                                });
                              }
                            },
                          );
                        }).toList(),
                        // ここまで置き換え
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 6),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xffA0A0A0), // ボーダーの色
                                width: 1.0, // ボーダーの太さ
                              ),
                            ),
                          ),
                          child: const Text(
                            '現在保存中の台情報',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        buildSaveCard(
                          purchaseDate: widget.resultUsage != null &&
                                  widget.resultUsage!.isNotEmpty
                              ? _formatDate(widget.resultUsage!['usage_date'])
                              : 'データなし',
                          productCount: widget.resultUsage != null &&
                                  widget.resultUsage!.isNotEmpty
                              ? widget.resultUsage!['usage_count'] ?? 0
                              : 0,
                          onUsePressed: (widget.resultUsage != null &&
                                  widget.resultUsage!.isNotEmpty &&
                                  (widget.resultUsage!['usage_count'] ?? 0) > 0)
                              ? () async {
                                  try {
                                    final response =
                                        await ApiService().fetchUsageData(
                                      usage_date:
                                          widget.resultUsage!['usage_date'],
                                    );

                                    print('APIレスポンス: $response');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SystemComparisonScreen(
                                          resultUsage: response['result_usage'],
                                          results: response['results'],
                                        ),
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              response['message'] ?? '成功')),
                                    );
                                  } catch (e) {
                                    print('エラー: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('エラーが発生しました: $e')),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              : null, // ← usage_countが0以下のときは押せない！
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading) // ローディング状態なら表示
                    Container(
                      color: Colors.black.withOpacity(0.5), // 背景を半透明に
                      child: Center(
                        child: CircularProgressIndicator(), // ローディングインジケータ
                      ),
                    ),
                ],
              )))
    ]);
  }
}

class DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashPainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget buildPurchaseCard({
  required String purchaseDate,
  required String productName,
  required String additionalInfo,
  required VoidCallback onUsePressed,
}) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左側: 購入情報
            Flexible(
              flex: 2, // 余白の割合を調整
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '購入日：$purchaseDate',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF737374),
                    ),
                  ),
                  SizedBox(height: 5),
                  // 商品名を折り返し可能に設定
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                    softWrap: true,
                    // overflow: TextOverflow.ellipsis, // テキストが長い場合に省略
                  ),
                  SizedBox(height: 5),
                  Text(
                    additionalInfo,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF737374),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10), // ボタンとの間隔
            // 右側: 使用ボタン (固定幅)
            SizedBox(
              width: 100, // ボタンの幅を固定
              child: ElevatedButton(
                onPressed: onUsePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A14CA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/footer/use-icon-top.png',
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '使用',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      CustomPaint(
        painter: DashPainter(
          color: Color(0xffA0A0A0),
          dashWidth: 4.0,
          dashSpace: 3.0,
          strokeWidth: 1.0,
        ),
        child: Container(height: 1), // 点線ボーダーの高さ
      ),
    ],
  );
}

Widget buildSaveCard({
  required String purchaseDate, // 購入日
  required int productCount, // 比較台数
  required VoidCallback? onUsePressed, // ボタンのアクション
  String? additionalInfo, // 任意の追加情報
}) {
  return Column(
    children: [
      // メインコンテナ
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // テキスト部分
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 購入日
                Text(
                  '使用日：$purchaseDate',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF737374),
                  ),
                ),
                const SizedBox(height: 5),
                // 比較台数
                Text(
                  '比較台数：$productCount台', // 台数を表示
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                // 追加情報（任意表示）
                if (additionalInfo != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    additionalInfo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF737374),
                    ),
                  ),
                ],
              ],
            ),
            // 続けるボタン
            ElevatedButton(
              onPressed: onUsePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A14CA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                '続ける',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      // 点線ボーダー
      CustomPaint(
        painter: DashPainter(
          color: const Color(0xffA0A0A0), // ボーダーの色
          dashWidth: 4.0, // 点線の幅
          dashSpace: 3.0, // 点線のスペース
          strokeWidth: 1.0, // 点線の太さ
        ),
        child: Container(height: 1), // 点線の高さ
      ),
    ],
  );
}
