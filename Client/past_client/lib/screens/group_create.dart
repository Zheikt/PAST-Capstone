import 'package:flutter/material.dart';
import 'package:past_client/classes/controller_collection_item.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/inset_edit_text_field_titled.dart';

class CreateGroupPage extends StatefulWidget {
  final WSConnector connection;
  final User user;

  const CreateGroupPage(
      {super.key, required this.connection, required this.user});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  int numOfStats = 1;
  TextEditingController nameController = TextEditingController();
  List<ControllerCollectionItem> kvControllers = [ControllerCollectionItem(2)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TitledInsetEditTextField(
              //Group name box
              title: "Group Name",
              textController: nameController,
            ),
            for (int value = 0; value < numOfStats; value++)
              Row(
                children: [
                  TitledInsetEditTextField(textController: kvControllers[value].getController(0), title: "Key"),
                  TitledInsetEditTextField(textController: kvControllers[value].getController(1), title: "Value"),
                ],
              )
          ],
        ),
      ),
    );
  }
}
