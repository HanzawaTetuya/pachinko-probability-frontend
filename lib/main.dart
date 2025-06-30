import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'auth/AccountCreation.dart'; // ← AccountCreationPage を import
import 'common_screen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'NotoSansJP'),
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');

          if (uri.path == '/account_creation') {
            final referralCode = uri.queryParameters['referral_code'];
            return MaterialPageRoute(
              builder: (_) => AccountCreationPage(referralCode: referralCode),
            );
          }

          if (uri.path == '/completed') {
            return MaterialPageRoute(
              builder: (_) =>
                  CommonScreen(initialIndex: 2), // ← このときだけSystemタブからスタート
            );
          }

          return MaterialPageRoute(builder: (_) => LoginPage());
        });
  }
}
