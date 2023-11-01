import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:past_client/classes/controller_collection_item.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/inset_edit_text_field_titled.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';

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
  final int maxNumberOfStats = 10;
  bool enableAddStatBtn = true;
  bool enableRemoveStatBtn = false;
  TextEditingController nameController = TextEditingController();
  final List<ControllerCollectionItem> kvControllers =
      List.generate(10, ((index) => ControllerCollectionItem(2)));

  void addStatPressHandler() {
    if (numOfStats < maxNumberOfStats) {
      setState(
        () => {
          numOfStats++,
          enableRemoveStatBtn = true,
          enableAddStatBtn = numOfStats < maxNumberOfStats
        },
      );
    } else {
      setState(
        () => enableAddStatBtn = false,
      );
    }
  }

  void removeStatPressHandler() {
    if (numOfStats > 1) {
      setState(
        () => {
          numOfStats--,
          enableAddStatBtn = true,
          enableRemoveStatBtn = numOfStats > 1
        },
      );
    } else {
      setState(
        () => enableRemoveStatBtn = false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: <Widget>[
          IconButton(
            //Returnr to Starting Page
            onPressed: () {
              //TODO: Rewrite to use popUntil()
              widget.connection.closeConnection();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) {
                  return const StartPage();
                }),
                (route) => false,
              );
            },
            icon: const Icon(Icons.groups),
          ),
          IconButton(
            //Go to UserProfile
            onPressed: () {
              //TODO: Rewrite to use popUntil()
              widget.connection.closeConnection();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) {
                  return UserProfile(
                    user: widget.user,
                    connection: widget.connection,
                  );
                }),
                (route) => false,
              );
            },
            icon: const Icon(Icons.person_sharp),
          ),
          IconButton(
            //Returnr to Starting Page
            onPressed: () {
              //TODO: Rewrite to use popUntil()
              widget.connection.closeConnection();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) {
                  return const StartPage();
                }),
                (route) => false,
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: LayoutGrid(
          columnSizes: [1.fr, 98.fr, 1.fr],
          rowSizes: [
            35.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            47.fr,
            7.fr,
          ],
          children: <Widget>[
            TitledInsetEditTextField(
              //Group name box
              title: "Group Name",
              textController: nameController,
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 1,
              rowSpan: 1,
            ),
            for (int value = 0; value < numOfStats; value++)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TitledInsetEditTextField(
                      textController: kvControllers[value].getController(0),
                      title: "Key",
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: DropdownMenu<Type>(
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: int, label: "Integer"),
                        DropdownMenuEntry(value: String, label: "Text"),
                        DropdownMenuEntry(value: double, label: "Decimal"),
                        DropdownMenuEntry(value: bool, label: "Boolean"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TitledInsetEditTextField(
                      textController: kvControllers[value].getController(1),
                      title: "Value",
                    ),
                  ),
                ],
              ).withGridPlacement(
                columnStart: 1,
                columnSpan: 1,
                rowStart: value + 2,
                rowSpan: 1,
              ),
            ElevatedButton(
              onPressed: enableAddStatBtn ? addStatPressHandler : null,
              child: const Text("Add Stat"),
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: numOfStats + 2,
              rowSpan: 1,
            ),
            ElevatedButton(
              onPressed: enableRemoveStatBtn ? removeStatPressHandler : null,
              child: const Text("Remove Stat"),
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: numOfStats + 3,
              rowSpan: 1,
            ),
          ],
        ),
      ),
    );
  }
}
