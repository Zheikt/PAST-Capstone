import 'package:flutter/material.dart';
import 'package:past_client/screens/login.dart';
import 'package:past_client/screens/register.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text((isLogin ? 'Register' : 'Login')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: (isLogin ? const LoginPage() : const RegisterPage()),
    );
  }
}
