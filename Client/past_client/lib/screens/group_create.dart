import 'package:flutter/material.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';

class CreateGroupPage extends StatefulWidget {
  final WSConnector connection;
  final User user;

  const CreateGroupPage(
      {super.key, required this.connection, required this.user});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              key: _formKey,
              decoration: const InputDecoration(labelText: "Enter Group Name"),
            ),
          ],
        ),
      ),
    );
  }
}
