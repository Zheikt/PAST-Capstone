import 'package:flutter/material.dart';
import 'package:past_client/screens/start_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P.A.S.T.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey.shade800,
        shadowColor: Colors.grey.shade900,
        textTheme: Typography.whiteRedmond,
        useMaterial3: true,
      ),
      home: const StartPage()
    );
  }
}

