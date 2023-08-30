import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:past_client/classes/auth_token.dart';
import 'package:past_client/screens/past_main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late Future<AuthToken> futureToken;
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _btnRegisterPressed() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(() {
        futureToken = _tryRegister();

        futureToken.then(
          (value) {
            log(value.toJson().toString());
            if (value.token.length < 20) {
              //register failed
            } else {
              //move to next page and connect to WS using this token
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PastMainPage(token: value),
                ),
              );
            }
          },
        );
      });
    }
  }

  Future<AuthToken> _tryRegister() async {
    final bytes = utf8.encode(passwordTextController.text);
    final base64Pass = base64.encode(bytes);
    try {
      final response =
          await http.post(Uri.parse('http://10.0.2.2:2024/h/r'), body: {
        'username': usernameTextController.text,
        "password": base64Pass,
        'email': emailTextController.text,
      });
      if (response.statusCode == 200) {
        log(response.body.toString());
        final data = jsonDecode(response.body);
        final tempToken = data['validAuthTokens'][0];
        tempToken['owner'] = data['id'];
        return AuthToken.fromJson(tempToken);
      } else if (response.statusCode == 404) {
        //login failed
        return const AuthToken(token: 'fail', validUntil: 0, owner: 'None');
      } else {
        //server-error
        throw Exception('Server-Error: ${response.statusCode}');
      }
    } catch (ex, stack) {
      log(ex.toString(), stackTrace: stack);
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
                'Please Register Below',
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: TextFormField(
                controller: passwordTextController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%*?.\\-_])[a-zA-z0-9!@#$%*?.\\-_]{8,}$')
                      .hasMatch(passwordTextController.text)) {
                    return 'Please enter a valid password (min. 8 caracters, 1 upper case, 1 lower case, 1 number, and 1 special character (! @ # \$ % & * ? . - _))';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.inverseSurface)),
                  labelText: 'Enter your password',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withAlpha(180),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: TextFormField(
                controller: emailTextController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                          r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
                      .hasMatch(emailTextController.text)) {
                    return 'Please a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.inverseSurface)),
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withAlpha(180),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _btnRegisterPressed,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
