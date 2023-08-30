import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:past_client/classes/auth_token.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/screens/group_select.dart';

class PastMainPage extends StatelessWidget {
  final AuthToken token;
  late final WSConnector connection = WSConnector('ws://10.0.2.2:2024/', token);
  final StreamController controller = StreamController.broadcast();
  late User? user = null;

  PastMainPage({super.key, required this.token}) {
    controller.addStream(connection.channel.stream);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          if (snapshot.data is String && snapshot.data == '__ping__') {
            connection.sendMessage(Request(
                operation: '__pong__',
                service: 'wss',
                data: {'__pong__': '__pong__'}));
          } else {
            final data = jsonDecode(snapshot.data.toString());
            if (data is! List && data['result'] == 'Successful Auth') {
              user = User.fromJson(data['data'][0]);
            }

            if (user != null) {
              return GroupSelect(
                connection: connection,
                user: user!,
                controller: controller,
              );
            }
          }
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Navigator.pop(context);
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
