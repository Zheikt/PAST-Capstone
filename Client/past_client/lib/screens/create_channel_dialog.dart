import 'dart:async';

import 'package:flutter/material.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/ws_connector.dart';

class CreateChannelDialog extends StatefulWidget {
  final WSConnector connection;
  final StreamController controller;
  final Group group;

  const CreateChannelDialog(
      {super.key,
      required this.connection,
      required this.group,
      required this.controller});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  late List<bool> selectedBoxes;
  late List<Widget> checkButtons;

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedBoxes = List.filled(widget.group.availableRoles.length, false);
    checkButtons = List.generate(
      widget.group.availableRoles.length,
      (index) => Checkbox(
        value: selectedBoxes[index],
        semanticLabel: widget.group.availableRoles.toList()[index].name,
        onChanged: (state) => setState(() {
          selectedBoxes[index] = !selectedBoxes[index];
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text('Create New Channel'),
        content: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the channel';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  labelText: 'Enter Channel Name',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withAlpha(180),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              height: 50,
              child: ListView(
                children: checkButtons,
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: null, child: const Text('Submit Channel')),
          TextButton(onPressed: null, child: const Text('Go to new Channel')),
        ],
      );
    });
  }
}
