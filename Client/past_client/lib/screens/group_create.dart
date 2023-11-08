import 'dart:developer';

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
  final List<bool> isNumList = List.generate(10, (index) => (index % 2 == 0));
  final ScrollController _scrollController = ScrollController();

  void addStatPressHandler() {
    if (numOfStats < maxNumberOfStats) {
      setState(
        () => {
          numOfStats++,
          enableRemoveStatBtn = true,
          enableAddStatBtn = numOfStats < maxNumberOfStats,
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
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: <Widget>[
          IconButton(
            //Go to SelectGroup
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
            //Return to Starting Page
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
            7.fr,
            15.fr,
            15.fr,
            15.fr,
            15.fr,
            15.fr,
            7.fr,
            8.fr,
            3.fr,
          ],
          children: <Widget>[
            TitledInsetEditTextField(
              //Group name box
              title: "Group Name",
              textController: nameController,
              isToggleable: false,
              titleSize: 18,
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 1,
              rowSpan: 1,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 7, bottom: 3),
                  child: Text(
                    "Base Stat Block",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 18),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: numOfStats,
                    itemBuilder: ((context, index) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: TitledInsetEditTextField(
                                textController:
                                    kvControllers[index].getController(0),
                                title: "Stat ${index + 1} Name",
                                isToggleable: false,
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: TitledInsetEditTextField(
                                textController:
                                    kvControllers[index].getController(1),
                                title: "Starting Value",
                                isToggleable: false,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 7, bottom: 3),
                                    child: Text(
                                      "Is Numeric",
                                      style: TextStyle(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  Checkbox(
                                    value: isNumList[index],
                                    onChanged: ((value) => setState(
                                          () {
                                            isNumList[index] =
                                                !isNumList[index];
                                          },
                                        )),
                                    semanticLabel: "Is Numeric",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 2,
              rowSpan: numOfStats > 4 ? 4 : numOfStats,
            ),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: ElevatedButton(
                    onPressed: enableAddStatBtn ? addStatPressHandler : null,
                    child: const Text("Add Stat"),
                  ),
                ),
                const Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.all(1),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: ElevatedButton(
                    onPressed:
                        enableRemoveStatBtn ? removeStatPressHandler : null,
                    child: const Text("Remove Stat"),
                  ),
                ),
              ],
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 2 + (numOfStats > 4 ? 4 : numOfStats),
              rowSpan: 1,
            ),
            Row(
              children: [
                const Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.all(1),
                  ),
                ),
                Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: () => log("Submit Pressed"),
                      child: const Text("Submit"),
                    )),
                const Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.all(1),
                  ),
                ),
              ],
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 7,
              rowSpan: 1,
            )
          ],
        ),
      ),
    );
  }
}
