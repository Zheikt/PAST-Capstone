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
        //brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 126, 110)),
        scaffoldBackgroundColor: Colors.grey.shade800,
        shadowColor: Colors.grey.shade900,
        textTheme: Typography.whiteRedmond,
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}
