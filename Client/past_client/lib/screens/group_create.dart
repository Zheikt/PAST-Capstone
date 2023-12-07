import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:past_client/classes/controller_collection_item.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/inset_edit_text_field_titled.dart';
import 'package:past_client/screens/group_channel_select.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';

class CreateGroupPage extends StatefulWidget {
  final WSConnector connection;
  final User user;
  final StreamController controller;

  const CreateGroupPage(
      {super.key,
      required this.connection,
      required this.user,
      required this.controller});

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

  final _formKey = GlobalKey<FormState>();

  bool letUserSubmit = true;
  RegExp groupNameRegExp = RegExp("[A-Z][A-Za-z0-9'. ]+");
  RegExp statNameRegExp = RegExp("[a-zA-Z]+( *([A-Z][a-z0-9]*)*)*");

  Group? newGroup;

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

  void submitGroupPressHandler() {
    if (_formKey.currentState!.validate()) {
      _createGroup();
      setState(() {
        letUserSubmit = false;
      });
    }
  }

  void _createGroup() {
    try {
      final statBlock = {};

      for (int index = 0; index < numOfStats; index++) {
        final currentControllerPair = kvControllers[index].controllers;
        statBlock[currentControllerPair[0].text] = isNumList[index]
            ? int.parse(currentControllerPair[1].text)
            : currentControllerPair[1].text;
      }
      final data = {
        "name": nameController.text,
        "statBlock": statBlock,
        "creatorId": widget.user.id,
        "creatorUsername": widget.user.username,
      };
      widget.connection.sendMessage(
          Request(operation: 'create', service: 'group', data: data));
    } catch (ex) {
      log("Error sending Create Group: ${ex.toString()}");
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
                    controller: widget.controller,
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
            7.fr,
            4.fr,
          ],
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TitledInsetEditTextField(
                    //Group name box
                    title: "Group Name",
                    textController: nameController,
                    isToggleable: false,
                    titleSize: 18,
                    validator: (p0) => p0!.trim().isEmpty
                        ? "Name cannot be empty or all whitepsaces"
                        : !groupNameRegExp.hasMatch(p0)
                            ? "Group must be at least 2 characters (A-Z, a-z, 0-9, .  ' ) and starting with a captial letter"
                            : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7, bottom: 3),
                    child: Text(
                      "Base Stat Block",
                      style:
                          TextStyle(color: Colors.grey.shade300, fontSize: 18),
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
                                  validator: ((p0) => p0!.trim().isEmpty
                                      ? "Statistic name cannot be empty or whitespace"
                                      : p0.trim().length < 2
                                          ? "Stat name must be at least 2 alphanumeric characters"
                                          : !statNameRegExp.hasMatch(p0)
                                              ? "Stat name must be a word or phrase at least 2 characters long with no special characters"
                                              : null),
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
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Starting value cannot be empty";
                                    }

                                    if (p0.trim().isEmpty) {
                                      return "Starting value cannot be only whitespace!";
                                    }

                                    if (isNumList[index]) {
                                      int? result = int.tryParse(p0);
                                      if (result == null) {
                                        return "This value must be a number!";
                                      }
                                    }

                                    return null;
                                  },
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
              ),
            ).withGridPlacement(
              columnStart: 1,
              columnSpan: 1,
              rowStart: 1,
              rowSpan: numOfStats > 3 ? 5 : numOfStats + 2,
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
              rowStart: 2 + (numOfStats > 3 ? 4 : numOfStats + 1),
              rowSpan: 1,
            ),
            // Row(
            //   children: [
            //     const Expanded(
            //       flex: 6,
            //       child: Padding(
            //         padding: EdgeInsets.all(1),
            //       ),
            //     ),
            //     Flexible(
            //       fit: FlexFit.loose,
            //       flex: 8,
            //       child: ElevatedButton(
            //         onPressed: letUserSubmit ? submitGroupPressHandler : null,
            //         style: ButtonStyle(
            //           backgroundColor:
            //               MaterialStateProperty.resolveWith((states) {
            //             if (states.contains(MaterialState.disabled)) {
            //               return Theme.of(context).colorScheme.inverseSurface;
            //             }
            //             return null;
            //           }),
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             if (!letUserSubmit)
            //               Padding(
            //                 padding: const EdgeInsets.fromLTRB(2, 1, 6, 1),
            //                 child: SizedBox(
            //                   width: 25,
            //                   height: 25,
            //                   child: CircularProgressIndicator(
            //                     color: Theme.of(context).colorScheme.secondary,
            //                   ),
            //                 ),
            //               ),
            //             const Text(
            //               "Submit",
            //               textAlign: TextAlign.end,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     const Expanded(
            //       flex: 6,
            //       child: Padding(
            //         padding: EdgeInsets.all(1),
            //       ),
            //     ),
            //   ],
            // ).withGridPlacement(
            //   columnStart: 1,
            //   columnSpan: 1,
            //   rowStart: 7,
            //   rowSpan: 1,
            // ),
            StreamBuilder(
                stream: widget.controller.stream,
                builder: (context, snapshot) {
                  // if (letUserSubmit) {
                  //   return const SizedBox(
                  //     width: 36,
                  //     height: 36,
                  //     child: Padding(padding: EdgeInsets.all(1)),
                  //   );
                  // }
                  if (snapshot.connectionState == ConnectionState.active &&
                      snapshot.hasData) {
                    if (snapshot.data != '__ping__' && snapshot.data is! List) {
                      log(snapshot.data.toString());
                      final data = jsonDecode(snapshot.data.toString());
                      if (data is List == false) {
                        switch (data['operation']) {
                          case 'create-group':
                            newGroup = Group.fromJson(data['response']);
                            break;
                        }
                      }
                    }
                  }

                  return Row(
                    children: [
                      const Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.all(1),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 8,
                        child: ElevatedButton(
                          onPressed: letUserSubmit
                              ? submitGroupPressHandler
                              : newGroup != null
                                  ? () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GroupChannelSelect(
                                            connection: widget.connection,
                                            user: widget.user,
                                            group: newGroup!,
                                            controller: widget.controller,
                                          ),
                                        ),
                                      )
                                  : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Theme.of(context)
                                    .colorScheme
                                    .inverseSurface;
                              }
                              return null;
                            }),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!letUserSubmit && newGroup == null)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 1, 6, 1),
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              Text(
                                newGroup == null ? "Submit" : "Go To Group!",
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.all(1),
                        ),
                      ),
                    ],
                  );
                }).withGridPlacement(
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
