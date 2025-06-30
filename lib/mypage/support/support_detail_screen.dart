import 'package:flutter/material.dart';
import 'package:system_alpha/api/api_service.dart';

class SupportDetailScreen extends StatefulWidget {
  final int questionId;

  const SupportDetailScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  _SupportDetailScreenState createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  String _question = '';
  String _answer = '';
  String _createdAt = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestionDetail();
  }

  Future<void> fetchQuestionDetail() async {
    final result = await ApiService().getAnswer(widget.questionId);
    setState(() {
      _question = result['question'] ?? '';
      _answer = result['answer'] ?? '';
      _createdAt = result['created_at']?.substring(0, 10) ?? '';
      _isLoading = false; // ← 読み込み完了
    });
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
        Container(width: 24, height: 24),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("サポート・ヘルプ"),
                    SizedBox(height: 20),
                    Text(
                      _question,
                      style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '作成日：$_createdAt',
                      style: TextStyle(fontSize: 12, color: Color(0xFF737374)),
                    ),
                    SizedBox(height: 24),
                    Text(
                      _answer,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
