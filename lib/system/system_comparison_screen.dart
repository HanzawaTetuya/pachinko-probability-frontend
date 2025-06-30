import 'package:flutter/material.dart';
import '../../system/system_screen.dart';
import 'package:system_alpha/api/api_service.dart';

class SystemComparisonScreen extends StatefulWidget {
  final Map<String, dynamic> resultUsage;
  final List<dynamic> results;

  const SystemComparisonScreen({
    Key? key,
    required this.resultUsage,
    required this.results,
  }) : super(key: key);

  @override
  _SystemComparisonScreenState createState() => _SystemComparisonScreenState();
}

class _SystemComparisonScreenState extends State<SystemComparisonScreen> {
  @override
  void initState() {
    super.initState();

    // デバッグ用ログ: データを確認
    debugPrint('デバッグ: resultUsage -> ${widget.resultUsage}');
    debugPrint('デバッグ: results -> ${widget.results}');
  }

  void showPopup(BuildContext context, {required Map<String, dynamic> data}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Container(
            width: 360,
            height: 460,
            child: Column(
              children: [
                // Image.asset('assets/comparison/number-tag-b-1.png'),
                Container(
                  width: double.infinity, // 親のContainerに横幅を指定
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xffD0D0D0), // ボーダーの色
                        width: 1.0, // ボーダーの太さ
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8), // テキスト間の余白
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 左寄せに設定
                    children: [
                      Text(
                        '台番号：${data['machine_number'] ?? '不明'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${data['product_name'] ?? '不明'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // 折り返しを有効にする
                        maxLines: 2, // 必要に応じて最大行数を指定
                        overflow: TextOverflow.ellipsis, // 溢れた場合の処理
                      ),
                    ],
                  ),
                ),
                buildProbabilityRow(
                  title: '100回以内に大当たりを引く確率',
                  probability: '${data['hit_probability'] ?? '不明'}',
                  unit: '%',
                ),
                buildProbabilityRow(
                  title: '${data['expected_chain_count'] ?? '不明'}回連チャンする確率',
                  probability: '${data['chain_probability'] ?? '不明'}',
                  unit: '%',
                ),
                buildProbabilityRow(
                  title: '予想収支',
                  subtitle: (('換金率4.0円・釘により変動')),
                  probability: '${data['cash_balance_3_3'] ?? '不明'}',
                  unit: '',
                  fontSize: 23,
                ),
                buildProbabilityRow(
                  title: '朝イチ台と比較した投資節約額',
                  probability: '${data['current_bonus'] ?? '不明'}',
                  unit: '円',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildComparison({
    required String machineNumber,
    required String machineName,
    required String winningProbability,
    required String estimatedProfit,
    int showImageIndex = 0, // 上位3つのアイテムに特定の画像を使用
    required Map<String, dynamic> result, // 各 result データを渡す
  }) {
    String? imagePath;
    if (showImageIndex == 1) {
      imagePath = 'assets/comparison/number-tag-s-1.png';
    } else if (showImageIndex == 2) {
      imagePath = 'assets/comparison/number-tag-s-2.png';
    } else if (showImageIndex == 3) {
      imagePath = 'assets/comparison/number-tag-s-3.png';
    }

    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 16, right: 10, left: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xffA0A0A0),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (imagePath != null) Image.asset(imagePath),
                              if (imagePath != null) SizedBox(width: 5),
                              Text(
                                '台番号：$machineNumber',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Container(
                            child: Text(
                              machineName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final resultNumber =
                              widget.resultUsage['result_number'];
                          final id = result['id'];

                          // API呼び出し
                          final resultDetail = await ApiService().getDataDetail(
                            resultNumber: resultNumber,
                            id: id,
                          );

                          print('APIレスポンス: $resultDetail');

                          // ポップアップを表示
                          showPopup(context, data: resultDetail);
                        } catch (e) {
                          print('エラー: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('エラーが発生しました: $e')),
                          );
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF4A14CA),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Image.asset(
                          'assets/detail-arrow-white.png',
                          width: 7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('大当たり確率：$winningProbability%'),
                    SizedBox(height: 8),
                    Text('予想収益：$estimatedProfit'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
    // resultsのソート処理
    final sortedResults = widget.results
        .where((result) => result['hit_probability'] != null) // nullチェック
        .toList();

    sortedResults.sort((a, b) => (b['hit_probability'] as num)
        .compareTo(a['hit_probability'] as num)); // 降順ソート

    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildHeader("台情報入力"),
            SizedBox(height: 20),
            // buildSearchRow(), // 検索ボックス

            // ソート済みの結果を利用してビルド
            ...sortedResults.asMap().entries.map((entry) {
              final index = entry.key; // 並べ替え後のインデックス
              final result = entry.value; // 並べ替え後の要素

              return buildComparison(
                machineNumber: result['machine_number']?.toString() ?? '不明',
                machineName: result['product_name'] ?? '商品名なし',
                winningProbability:
                    result['hit_probability']?.toStringAsFixed(2) ?? '0.00',
                estimatedProfit: result['cash_balance_3_3'] ?? '不明',
                showImageIndex: index < 3 ? index + 1 : 0, // 上位3つにインデックス付与
                result: result,
              );
            }).toList(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSearchRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF815BDA), // 背景色
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/search.png', // アイコンの画像パス
            width: 21,
            height: 21,
          ),
        ),
        SizedBox(width: 8),

        // 中央の検索フィールド
        Expanded(
          child: TextField(
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '商品を検索',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSmallProbabilityCard({
    required String title,
    required String probability,
    required String unit,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft, // 左寄せ
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
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
                        fontSize: 45,
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

  Widget buildProbabilityRow({
    required String title, // 左側のタイトルテキスト
    required String probability, // 確率の数値部分
    required String unit, // 確率の単位（例: %）
    double fontSize = 30, // デフォルトのフォントサイズ
    String? subtitle, // オプションのサブタイトル
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
            children: [
              Align(
                alignment: Alignment.centerLeft, // 左寄せ
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (subtitle != null) // サブタイトルがある場合のみ表示
                Align(
                  alignment: Alignment.centerLeft, // 左寄せ
                  child: Container(
                    padding: EdgeInsets.only(top: 4), // タイトルとサブタイトルの間の余白
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600], // サブタイトルの色を控えめに
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight, // 右寄せ
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // サブタイトルも右揃え
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          probability,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: fontSize, // オプションのフォントサイズを適用
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // 点線ボーダーとの間に少し余白を入れる
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
      ),
    );
  }
}
