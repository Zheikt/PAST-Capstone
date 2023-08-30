import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:past_client/parts/hidden_toggleable_text_form_field.dart';
import 'package:past_client/classes/auth_token.dart';
import 'package:past_client/screens/past_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Future<AuthToken> futureToken;
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  void _btnLoginPressed() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(() {
        futureToken = _tryLogin();

        futureToken.then((value) => {
              log('data: ${value.token}'),
              if (value.token.length < 20)
                {
                  //login failed
                }
              else
                {
                  //move to next page and connect to WS using this token
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PastMainPage(token: value),
                      ))
                }
            });
      });
    }
  }

  Future<AuthToken> _tryLogin() async {
    final bytes = utf8.encode(passwordTextController.text);
    final base64Pass = base64.encode(bytes);
    log('pass: $base64Pass, user: ${usernameTextController.text}');
    try {
      final response = await http.post(Uri.parse('http://10.0.2.2:2024/h/l'),
          body: {
            'username': usernameTextController.text,
            "password": base64Pass
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tempToken = data['token'];
        tempToken['owner'] = data['userId'];
        return AuthToken.fromJson(tempToken);
      } else if (response.statusCode == 404) {
        //login failed
        return const AuthToken(token: 'fail', validUntil: 0, owner: 'None');
      } else {
        //server-error
        throw Exception('Server-Error: ${response.statusCode}');
      }
    } catch (ex) {
      return const AuthToken(
          token: 'Connection Failed', validUntil: 0, owner: 'None');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Text(
                'Welcome to P.A.S.T.',
                style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.primaryContainer),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Text(
                'Please Login Below',
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(180)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: TextFormField(
                controller: usernameTextController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.inverseSurface)),
                  labelText: 'Enter your username',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withAlpha(180),
                  ),
                ),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: HiddenToggleableTextFormField(
                  passwordTextController: passwordTextController),
            ),
            ElevatedButton(
              onPressed: _btnLoginPressed,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
