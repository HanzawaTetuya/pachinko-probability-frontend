import 'package:flutter/material.dart';
import 'package:system_alpha/system/system_comparison_screen.dart';
import 'package:system_alpha/api/api_service.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SystemResultScreen extends StatefulWidget {
  final String rotation; // 回転数
  final String machineNumber; // 台の番号
  final String initialHits; // 初当たり数
  final String totalHits; // 大当たり数
  final int productNumber; // 商品番号
  final String licenseId; // ライセンスID
  final String productName; // 商品名
  final double adjustedProbability100; // 100回以内に大当たり確率
  final double adjustedChainExpectation; // 調整された連チャン期待値
  final String adjustedProfitRange; // 調整された利益範囲
  final double probMoreThanAdjusted; // 調整以上の確率
  final String rangeResult; // 範囲の結果
  final String usage_date;

  const SystemResultScreen({
    Key? key,
    required this.rotation,
    required this.machineNumber,
    required this.initialHits,
    required this.totalHits,
    required this.productNumber,
    required this.licenseId,
    required this.productName,
    required this.adjustedProbability100,
    required this.adjustedChainExpectation,
    required this.adjustedProfitRange,
    required this.probMoreThanAdjusted,
    required this.rangeResult,
    required this.usage_date,
  }) : super(key: key);

  @override
  _SystemResultScreenState createState() => _SystemResultScreenState();
}

class _SystemResultScreenState extends State<SystemResultScreen> {
  bool _isLoading = false; // ローディング状態を管理
  @override
  void initState() {
    super.initState();

    // デバッグ用ログ
    print("受け取った 台番号: ${widget.machineNumber.runtimeType}");
    print("受け取った 商品名: ${widget.productName.runtimeType}");
    print("受け取った 100回以内の大当たり確率: ${widget.adjustedProbability100.runtimeType}");
    print("受け取った 調整された連チャン期待値: ${widget.adjustedChainExpectation.runtimeType}");
    print("受け取った 調整された利益範囲: ${widget.adjustedProfitRange.runtimeType}");
    print("受け取った 調整以上の確率: ${widget.probMoreThanAdjusted.runtimeType}");
    print("受け取った 範囲結果: ${widget.rangeResult.runtimeType}");
  }

  void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'どの機種で計算しますか？',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            height: 140,
            width: 360,
            child: Column(
              children: [
                buildButton(
                    label: '同機種',
                    backgroundColor: Color(0xFF565260),
                    onPressed: () {
                      //
                    }),
                buildButton(
                    label: '別機種',
                    backgroundColor: Color(0xFF565260),
                    onPressed: () {
                      //
                    }),
              ],
            ),
          ),
        );
      },
    );
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
  // 支払管理とログアウトボタンを表示するメソッド

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
            _buildHeader("計算結果"),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xFFA0A0A0)))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '台番号：${widget.machineNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.productName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      buildProbabilityCard(
                        title: '100回以内に大当たりを引く確率',
                        probability: '${widget.adjustedProbability100}',
                        unit: '%',
                      ),
                      buildProbabilityCard(
                        title: '${widget.adjustedChainExpectation}回以上連チャンする確率',
                        probability: '${widget.probMoreThanAdjusted}',
                        unit: '%',
                      ),
                      buildProbabilityCard(
                        title: '予想収支',
                        subtitle: '(換金率4.0円・釘により変動)',
                        probability: '${widget.adjustedProfitRange}',
                        unit: '',
                        probabilityFontSize: 25, // フォントサイズを指定
                      ),
                      buildProbabilityCard(
                        title: '朝イチ台と比較した投資節約額',
                        probability: '${widget.rangeResult}',
                        unit: '円',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: buildHalfButton(
                  label: '比較',
                  onPressed: () async {
                    try {
                      // ローディングインジケータを表示するなど、非同期処理開始をユーザーに通知
                      setState(() {
                        _isLoading = true;
                      });

                      // API呼び出し
                      final response = await ApiService().fetchUsageData(
                        usage_date: widget.usage_date, // 修正箇所
                      );

                      // デバッグ: APIレスポンスを確認
                      print('APIレスポンス: $response');

                      if (response['success'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SystemComparisonScreen(
                              resultUsage: response['result_usage'],
                              results: response['results'],
                            ),
                          ),
                        );
                      } else {
                        // エラーメッセージを表示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message'] ?? 'エラーが発生しました。'),
                          ),
                        );
                      }
                    } catch (e) {
                      print('エラー: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('エラーが発生しました: $e'),
                        ),
                      );
                    } finally {
                      // ローディングインジケータを非表示にする
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ))
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget buildInputField({
    required String title, // 1つ目のTextの内容
    String? subtitle, // 2つ目のTextの内容（nullの場合は非表示）
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 12,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF818181),
                fontSize: 10,
              ),
            ),
          ],
          SizedBox(
              height: subtitle != null ? 8 : 8), // サブタイトルがあるときは16、ないときは8の余白
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Color(0xFF4A14CA)), // フォーカス時のボーダー色
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHalfButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF4A14CA), // デフォルトの背景色
    double topPadding = 15.0, // デフォルトの上部余白を設定
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding), // ボタン上部の余白
        Container(
          width: double.infinity, // 横幅を画面いっぱいに
          height: 60, // 高さを60に設定
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor, // カスタマイズ可能な背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // ボタンの角丸
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

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF4A14CA), // デフォルトの背景色
    double topPadding = 15.0, // デフォルトの上部余白を設定
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding), // ボタン上部の余白
        Container(
          width: double.infinity, // 横幅を画面いっぱいに
          height: 44, // 高さを60に設定
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor, // カスタマイズ可能な背景色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // ボタンの角丸
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

Widget buildProbabilityCard({
  required String title,
  String? subtitle, // オプションの subtitle 引数
  required String probability,
  required String unit,
  double probabilityFontSize = 45, // デフォルト値を設定
}) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft, // 左寄せ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (subtitle != null) // subtitle が指定されている場合のみ表示
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // 少し余白を追加
                      child: Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight, // 右寄せ
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    probability,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: probabilityFontSize, // 動的なフォントサイズ
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomPaint(
          painter: DashPainter(
            color: Color(0xffA0A0A0),
            dashWidth: 4.0,
            dashSpace: 3.0,
            strokeWidth: 1.0,
          ),
          child: Container(height: 1), // 点線ボーダーの高さ
        ),
      ),
    ],
  );
}
