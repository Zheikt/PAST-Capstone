import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/member.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/screens/group_channel_select.dart';

class GroupSearchBody extends StatefulWidget {
  final User user;
  final WSConnector connection;
  final StreamController controller;
  // final List<Group> testSearchGroups = [
  //   Group(id: 'g-7n8n9n', name: "Gridiron Pantheon", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-789012', nickname: "Coach S", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "Yards Per Game": 0,
  //     "Tackles Per Game": 0,
  //     "offensivePosition": "Bench",
  //     "defensivePosition": "Bench",
  //   }),
  //   Group(id: 'g-0n8n6n', name: "Lucky LOLers", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-789012', nickname: "Coach S", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "killDeathRatio": 0,
  //     "averageKillsPerGame": 0,
  //     "operator": "Unknown"
  //   }),
  //   Group(id: 'g-4n2n9n', name: "Mat Monsters", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-789012', nickname: "Coach S", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "pointsPerMatch": 0,
  //     "avgTimeToPin": 0,
  //     "choicePosition": "bottom",
  //     "wins": 0
  //   }),
  //   Group(id: 'g-7n8n9n', name: "No Luck Allowed", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-789012', nickname: "Coach S", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "Yards Per Game": 0,
  //     "Tackles Per Game": 0,
  //     "offensivePosition": "Bench",
  //     "defensivePosition": "Bench",
  //   })
  // ];

  GroupSearchBody(
      {super.key,
      required this.user,
      required this.connection,
      required this.controller});

  @override
  State<GroupSearchBody> createState() => _GroupSearchBodyState();
}

class _GroupSearchBodyState extends State<GroupSearchBody> {
  List<Group>? searchedGroups = null;
  bool isSearch = false; //Consider making this its own page
  TextEditingController searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //Use Test Data
    //searchedGroups = [];
    //Gets user groups
    // widget.connection.sendMessage(Request(
    //     operation: 'get-user-groups',
    //     service: 'group',
    //     data: {'userId': widget.user.id}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          // child: LayoutGrid(
          //   columnSizes: [1.fr, 18.fr, 1.fr],
          //   rowSizes: [2.fr, 4.fr, 4.fr, 16.fr, 2.fr],
          //   rowGap: 10,
          child: Flexible(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search for a Group to join!',
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                    ),
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Search cannot be emepty',
                  ),
                ),
                //.withGridPlacement(columnStart: 1, columnSpan: 1, rowStart: 2, rowSpan: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.connection.sendMessage(
                          Request(
                            operation: 'get-group-by-name',
                            service: 'group',
                            data: {'name': searchController.text},
                          ),
                        );

                        //Test Search
                        // setState(() {
                        //   searchedGroups = widget.testSearchGroups
                        //       .where((element) => element.name.contains(RegExp(
                        //           searchController.text,
                        //           caseSensitive: false)))
                        //       .toList();
                        // });
                      }
                    },
                    child: const Text('Search'),
                  ),
                ), //.withGridPlacement(columnStart: 1, rowStart: 3),
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          indent: 4,
          endIndent: 4,
          color: Color.fromARGB(148, 144, 164, 174),
        ),
        StreamBuilder(
          stream: widget.controller.stream,
          builder: (context, snapshot) {
            Widget child = const Text(
                "Search for a Group to join! See your results here!");
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData &&
                snapshot.data is! List &&
                snapshot.data != '__ping__') {
              final data = jsonDecode(snapshot.data.toString());
              switch (data['operation']) {
                case 'get-group-by-name':
                  //Set groups found by search
                  searchedGroups = List.generate(data['response'].length,
                      (index) => Group.fromJson(data['response'][index]));
                  break;
                case 'join-group':
                  Group joinedGroup = Group.fromJson(data['response']);
                  widget.user.groupIds.add(joinedGroup.id);
                  joinedGroup.members.add(Member(
                      userId: widget.user.id,
                      nickname: widget.user.username,
                      roles: []));
                  widget.user.stats.add({
                    'groupId': joinedGroup.id,
                    'stats': joinedGroup.defaultStatBlock
                  });
                  return AlertDialog(
                    title: Text(
                      "You've joined ${joinedGroup.name}!",
                    ),
                    content: Text(
                      "You are now ${joinedGroup.name}'s newest member! Select 'Continue' to see the group or 'Back' to join more Groups!",
                    ),
                    contentTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChannelSelect(
                              connection: widget.connection,
                              user: widget.user,
                              group: joinedGroup,
                              controller: widget.controller,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                        ),
                      ),
                      TextButton(
                        onPressed: () {searchedGroups = null; Navigator.pop(context);},
                        child: const Text(
                          'Back',
                        ),
                      ),
                    ],
                  );
              }
            }

            if (searchedGroups != null) {
              child = searchedGroups!.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchedGroups!.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                            title: Text(searchedGroups![index].name),
                            leading: CircleAvatar(
                                child: Text(searchedGroups![index].name[0])),
                            trailing: const Icon(Icons.add),
                            onTap: () {
                              //Add User to Group, then navigate to Group
                              widget.connection.sendMessage(
                                Request(
                                  operation: 'join-group',
                                  service: 'group',
                                  data: {
                                    'userId': widget.user.id,
                                    'groupId': searchedGroups![index].id,
                                    'username': widget.user.username
                                  },
                                ),
                              );
                            });
                      }),
                    )
                  : const Text("No Groups have matched your search");
            }

            return Flexible(flex: 4, child: child);
          },
        ),
        // searchedGroups != null
        //     ? //replace with StreamBuilder to connect to Backend
        //     searchedGroups!.isNotEmpty
        //         ? Flexible(
        //             flex: 4,
        //             child: ListView.builder(
        //               itemCount: searchedGroups!.length,
        //               itemBuilder: ((context, index) {
        //                 return ListTile(
        //                     title: Text(searchedGroups![index].name),
        //                     leading: CircleAvatar(
        //                         child: Text(searchedGroups![index].name[0])),
        //                     trailing: const Icon(Icons.add),
        //                     onTap: () {
        //                       //Add User to Group, then naviagte to Group
        //                       Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                           builder: (context) => GroupChannelSelect(
        //                             connection: widget.connection,
        //                             user: widget.user,
        //                             group: searchedGroups![index],
        //                             controller: widget.controller,
        //                           ),
        //                         ),
        //                       );
        //                     });
        //               }),
        //             ),
        //           ) //.withGridPlacement(columnStart: 1, rowStart: 4)
        //         : const Flexible(
        //             flex: 2,
        //             child: Text("No Groups have matched your search"),
        //           )
        //     //.withGridPlacement(columnStart: 1, rowStart: 4),
        //     : const Flexible(
        //         flex: 4,
        //         child:
        //             Text("Search for a Group to join! See your results here!"),
        //       ),
      ],
    );
  }
}
