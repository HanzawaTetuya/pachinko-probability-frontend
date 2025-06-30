import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter を使うために必要
import 'system_result_screen.dart';
import 'package:system_alpha/api/api_service.dart';

class SystemInputScreen extends StatefulWidget {
  final int productNumber;
  final String licenseId;
  final String productName;

  const SystemInputScreen({
    Key? key,
    required this.productNumber,
    required this.licenseId,
    required this.productName,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<SystemInputScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // ローディング状態を管理

  // 各フィールドのコントローラーを追加
  final TextEditingController rotationController = TextEditingController();
  final TextEditingController machineNumberController = TextEditingController();
  final TextEditingController initialHitsController = TextEditingController();
  final TextEditingController totalHitsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // デバッグ用ログ
    print("受け取った productNumber: ${widget.productNumber}");
    print("受け取った licenseId: ${widget.licenseId}");
    print("受け取った productName: ${widget.productName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // ← のびるスクロール感
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey, // フォーム全体を管理
          child: Column(
            children: [
              _buildHeader("台情報入力"),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.productName, // productNameを表示
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    buildInputField(
                        title: '台の番号', controller: machineNumberController),
                    buildInputField(
                        title: '総回転数', controller: rotationController),
                    buildInputField(
                        title: '初当たり回数', controller: initialHitsController),
                    buildInputField(
                        title: '大当たり総数', controller: totalHitsController),
                    buildButton(
                        label: '計算する',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // バリデーションが成功した場合に次の画面に遷移
                            final String machineNumber =
                                machineNumberController.text;
                            final String rotation = rotationController.text;
                            final String initialHits =
                                initialHitsController.text;
                            final String totalHits = totalHitsController.text;

                            // ローディング表示を管理するための状態設定
                            setState(() {
                              _isLoading = true; // ローディング開始
                            });

                            try {
                              // API呼び出し
                              final response = await ApiService().calculate(
                                productNumber: widget.productNumber,
                                licenseId: widget.licenseId,
                                productName: widget.productName,
                                machineNumber: machineNumber,
                                rotation: rotation,
                                initialHits: initialHits,
                                totalHits: totalHits,
                              );

                              // レスポンス確認とデバッグ出力
                              print("API呼び出し成功: レスポンスデータ: $response");

                              if (response['success'] == true) {
                                // 成功メッセージの表示
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(response['message'] ?? "計算成功！")),
                                );

                                // レスポンスのデータをデバッグ表示
                                final data = response['data'];
                                print("受け取った計算データ: $data");

                                // 次の画面に遷移
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SystemResultScreen(
                                      rotation: rotation,
                                      machineNumber: machineNumber,
                                      initialHits: initialHits,
                                      totalHits: totalHits,
                                      productNumber: widget.productNumber,
                                      licenseId: widget.licenseId,
                                      productName: widget.productName,
                                      adjustedProbability100:
                                          data['adjusted_probability_100'],
                                      adjustedChainExpectation:
                                          data['adjusted_chain_expectation'],
                                      adjustedProfitRange:
                                          data['adjusted_profit_range'],
                                      probMoreThanAdjusted:
                                          data['prob_more_than_adjusted'],
                                      rangeResult: data['range_result'],
                                      usage_date: data['usage_date'],
                                    ),
                                  ),
                                );
                              } else {
// 403のエラーメッセージ表示（赤いSnackBar）
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        response['message'] ?? "エラーが発生しました"),
                                    backgroundColor:
                                        Colors.red, // 🔴 ← これで赤くなる！
                                  ),
                                );
                              }
                            } catch (e) {
                              // エラー時の処理
                              print("API呼び出しエラー: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("APIエラーが発生しました: $e")),
                              );
                            } finally {
                              setState(() {
                                _isLoading = false; // ローディング終了
                              });
                            }
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String title,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number, // 数字専用キーボードを表示
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 数字のみ入力を許可
            ],
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$title は必須項目です'; // バリデーションエラーメッセージ
              }
              return null; // 問題ない場合は null を返す
            },
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String label,
    required VoidCallback onPressed,
    double topPadding = 40.0, // デフォルトの上部余白を設定
  }) {
    return Column(
      children: [
        SizedBox(height: topPadding), // ボタン上部の余白
        Container(
          width: double.infinity, // 横幅を画面いっぱいに
          height: 44, // 高さを44に設定
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A14CA), // ボタンの背景色
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
}
