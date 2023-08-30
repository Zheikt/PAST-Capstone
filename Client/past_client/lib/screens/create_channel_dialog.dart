import 'package:flutter/material.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/ws_connector.dart';

class CreateChannelDialog extends StatefulWidget {
  final WSConnector connection;
  final Group group;

  const CreateChannelDialog(
      {super.key, required this.connection, required this.group});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  late List<bool> selectedBoxes;

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedBoxes = List.filled(widget.group.availableRoles.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Create New Channel'),
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
                color:
                    Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
              ),
            ),
          ),
        ),
        ListView.builder(
          itemBuilder: (context, index) {
            return CheckboxListTile(
              value: selectedBoxes[index],
              onChanged: (state) => setState(() {
                selectedBoxes[index] = !selectedBoxes[index];
              }),
            );
          },
        ),
      ],
    );
  }
}
