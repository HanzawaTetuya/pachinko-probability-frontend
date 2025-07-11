import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01020C),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 20, bottom: 40), // 下にも余白追加
        child: Column(
          children: [
            SizedBox(height: 40),
            _buildHeader(context, "プライバシーポリシー"),
            SizedBox(height: 20),
            Text(
              '''株式会社SIGMA（以下、「当社」といいます。）は、当社が提供するサービス「システムアルファ」（以下、「本サービス」といいます。）において取得するユーザーの個人情報の取扱いについて、以下のとおりプライバシーポリシー（以下、「本ポリシー」といいます。）を定めます。

第1条（個人情報）
本ポリシーにおいて「個人情報」とは、個人情報保護法で定める「個人情報」を指し、氏名、生年月日、住所、電話番号、連絡先、その他の記述等により特定の個人を識別できる情報、および個人識別符号（顔画像、指紋、声紋、保険者番号など）を指します。

第2条（個人情報の収集方法）
当社はユーザーが登録する際に、氏名、生年月日、住所、電話番号、メールアドレス、銀行口座番号、クレジットカード情報等の個人情報を取得する場合があります。また、ユーザーと提携先の間で行われた取引に関する記録（決済情報を含む）を、当社の提携先から収集することがあります。

第3条（個人情報の利用目的）
当社は取得した個人情報を以下の目的で利用します。
本サービスの提供・運営のため
本人確認およびユーザーからのお問い合わせ対応のため
サービスの更新情報、キャンペーン情報、関連サービス等のご案内のため
メンテナンスおよび重要なお知らせのため
利用規約に違反したユーザー、不正利用を目的としたユーザーを特定・利用停止措置を行うため
ユーザーに登録情報の確認・変更・削除および利用状況を確認いただくため
有料サービス利用料金の請求処理のため
その他、上記利用目的に付随する目的のため

第4条（利用目的の変更）
当社は、変更前の利用目的と関連性があり合理的であると認められる場合に限り、個人情報の利用目的を変更します。利用目的を変更した場合は、変更後の内容をウェブサイトで通知・公表いたします。

第5条（個人情報の第三者提供）
当社は、以下の場合を除き、事前にユーザーの同意を得ることなく第三者に個人情報を提供することはありません。
法令に基づき必要と認められる場合
人の生命・身体・財産保護のために必要があり、本人の同意を得ることが困難な場合
公衆衛生の向上・児童の健全育成のために特に必要があり、本人の同意を得ることが困難な場合
国の機関または地方公共団体等の法令上の事務を支援するために必要な場合で、本人の同意取得が事務遂行に支障を及ぼす場合
上記にかかわらず、以下の場合は第三者への提供には該当しません。
利用目的達成の範囲で、業務委託先に個人情報を提供する場合
合併その他の事業承継に伴い個人情報を提供する場合
個人情報を共同利用する場合で、利用目的、利用者の範囲、管理責任者を明示している場合

第6条（個人情報の開示）
ユーザーが自己の個人情報の開示を求めた場合、当社は本人確認の上、速やかに開示します。ただし、以下の場合は一部または全部を開示できない場合があります。開示できない場合はその理由を通知いたします。
※開示請求については原則として無償で対応いたしますが、特別な対応が必要な場合は手数料をいただく場合があります。
本人または第三者の生命・身体・財産等の権利利益を害する場合
当社業務に著しい支障を及ぼす場合
法令に違反する場合

第7条（個人情報の訂正・削除）
ユーザーは、自己の個人情報に誤りがある場合、当社の定める手続きにより訂正・追加・削除を求めることができます。当社は請求に応じて速やかに対応し、対応結果を通知します。

第8条（個人情報の利用停止等）
ユーザーが、個人情報が利用目的外または不正に取得されたとして利用停止や消去を求めた場合、当社は調査の上、適切な対応を速やかに行い、結果を通知します。
ただし、利用停止等が困難で代替措置によりユーザーの権利利益が保護される場合は、代替措置を講じます。

第9条（プライバシーポリシーの変更）
当社は必要に応じて本ポリシーを変更する場合があります。変更後の内容はウェブサイト掲載後ただちに効力を生じるものとします。

第10条（安全管理措置）
当社は個人情報の漏洩、滅失、毀損等を防止するため、適切な安全管理措置を講じ、従業員および委託先への監督を徹底します。

第11条（お問い合わせ窓口）
本ポリシーに関するお問い合わせ、ご質問、ご意見については、当サービス内のお問い合わせフォームよりご連絡ください。''',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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
}
