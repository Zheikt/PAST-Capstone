import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/member.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/partials/joined_groups.dart';
import 'package:past_client/screens/group_channel_select.dart';
import 'package:past_client/screens/group_create.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';
import 'package:past_client/partials/group_search.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class GroupSelect extends StatefulWidget {
  final WSConnector connection;
  final User user;
  final StreamController controller;
  // final List<Group> testGroups = [
  //   Group(id: 'g-1n2n3n', name: "The Rack", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-123456', nickname: "Masse Master", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "shotMakePercentage": -1,
  //     "ladderRank": -1
  //   }),
  //   Group(id: 'g-4n5n6n', name: "BO3 E-Sports", channels: [
  //     {'c-1m2m3m': "general"},
  //     {'c-4m5m6m': "off-topic"},
  //     {'c-7m8m9m': "admin-convo"},
  //   ], members: [
  //     Member(userId: 'u-123456', nickname: "Almost Good", roles: [])
  //   ], availableRoles: {}, defaultStatBlock: <String, dynamic>{
  //     "gamesPlayed": 0,
  //     "kill-deathRatio": 0,
  //     "averageKillsPerGame": 0,
  //     "preferredWeapon": "Unknown"
  //   })
  // ];
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

  GroupSelect(
      {super.key,
      required this.connection,
      required this.user,
      required this.controller});

  @override
  State<GroupSelect> createState() => _GroupSelectState();
}

class _GroupSelectState extends State<GroupSelect> {
  List<Group>? joinedGroups = null;
  List<Group>? searchedGroups = null;
  bool isSearch = false; //Consider making this its own page
  TextEditingController searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //Use Test Data
    //joinedGroups = widget.testGroups;
    searchedGroups = [];
    //Gets user groups
    widget.connection.sendMessage(
      Request(
        operation: 'get-user-groups',
        service: 'group',
        data: {'userId': widget.user.id},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearch ? const Text('Join a Group') : const Text('Groups'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: <Widget>[
          IconButton(
            //Create new Group
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return CreateGroupPage(
                    connection: widget.connection,
                    user: widget.user,
                    controller: widget.controller,
                  );
                }),
              );
            },
            icon: const Icon(Icons.add_circle_sharp),
          ),
          IconButton(
            //Search for Group
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            //View User Profile
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return UserProfile(
                    user: widget.user,
                    connection: widget.connection,
                    controller: widget.controller,
                  );
                }),
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
          child: isSearch
              ? GroupSearchBody(
                  user: widget.user,
                  connection: widget.connection,
                  controller: widget.controller,
                )
              : JoinedGroupsBody(
                  user: widget.user,
                  connection: widget.connection,
                  controller: widget.controller,
                )
          // child: Column(
          //   children: <Widget>[
          //     isSearch
          //         ? //the search results are not currently shown
          //         LayoutGrid(
          //             columnSizes: [1.fr, 18.fr, 1.fr],
          //             rowSizes: [4.fr, 4.fr, 4.fr, 4.fr, 4.fr],
          //             rowGap: 10,
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.symmetric(
          //                     vertical: 5, horizontal: 15),
          //                 child: TextFormField(
          //                   key: _formKey,
          //                   controller: searchController,
          //                   decoration: InputDecoration(
          //                     labelText: 'Search for a Group to join!',
          //                     labelStyle: TextStyle(
          //                         color: Theme.of(context)
          //                             .colorScheme
          //                             .inverseSurface),
          //                   ),
          //                   validator: (value) => value!.isNotEmpty
          //                       ? null
          //                       : 'Search cannot be emepty',
          //                 ),
          //               ).withGridPlacement(
          //                   columnStart: 1,
          //                   columnSpan: 1,
          //                   rowStart: 2,
          //                   rowSpan: 1),
          //               Padding(
          //                 padding: const EdgeInsets.symmetric(
          //                     vertical: 5, horizontal: 15),
          //                 child: ElevatedButton(
          //                   style: const ButtonStyle(
          //                     maximumSize: MaterialStatePropertyAll(
          //                       Size(
          //                         80,
          //                         40,
          //                       ),
          //                     ),
          //                   ),
          //                   onPressed: () {
          //                     if (_formKey.currentState!.validate()) {
          //                       // widget.connection.sendMessage(
          //                       //   Request(
          //                       //     operation: 'get-group-by-name',
          //                       //     service: 'group',
          //                       //     data: {'name': searchController.value},
          //                       //   ),
          //                       // );

          //                       //Test Search
          //                       //TODO: Wrap in setState((){...})
          //                       searchedGroups = widget.testSearchGroups
          //                           .where((element) => element.name.contains(
          //                               RegExp(searchController.text,
          //                                   caseSensitive: false)))
          //                           .toList();
          //                     }
          //                   },
          //                   child: const Text('Search'),
          //                 ),
          //               ).withGridPlacement(columnStart: 1, rowStart: 3),
          //               if (searchedGroups != null)
          //                 searchedGroups!.isNotEmpty
          //                     ? ListView.builder(
          //                             itemCount: searchedGroups!.length,
          //                             itemBuilder: ((context, index) {
          //                               return ListTile(
          //                                   title:
          //                                       Text(searchedGroups![index].name),
          //                                   leading: CircleAvatar(
          //                                       child: Text(searchedGroups![index]
          //                                           .name[0])),
          //                                   trailing:
          //                                       const Icon(Icons.arrow_forward),
          //                                   onTap: () {
          //                                     Navigator.push(
          //                                       context,
          //                                       MaterialPageRoute(
          //                                         builder: (context) =>
          //                                             GroupChannelSelect(
          //                                           connection: widget.connection,
          //                                           user: widget.user,
          //                                           group: searchedGroups![index],
          //                                           controller: widget.controller,
          //                                         ),
          //                                       ),
          //                                     );
          //                                   });
          //                             }))
          //                         .withGridPlacement(columnStart: 1, rowStart: 4)
          //                     : const Text("No groups matched your search")
          //                         .withGridPlacement(columnStart: 1, rowStart: 4),
          //             ],
          //           )
          //         : ListView.builder(
          //             itemCount: joinedGroups!.length,
          //             shrinkWrap: true,
          //             itemBuilder: (context, index) {
          //               return ListTile(
          //                   title: Text(joinedGroups![index].name),
          //                   leading: CircleAvatar(
          //                       child: Text(joinedGroups![index].name[0])),
          //                   trailing: const Icon(Icons.arrow_forward),
          //                   onTap: () {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                         builder: (context) => GroupChannelSelect(
          //                           connection: widget.connection,
          //                           user: widget.user,
          //                           group: joinedGroups![index],
          //                           controller: widget.controller,
          //                         ),
          //                       ),
          //                     );
          //                   });
          //             },
          //           )
          // StreamBuilder(
          //   stream: widget.controller.stream,
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.active &&
          //         snapshot.hasData) {
          //       final data = jsonDecode(snapshot.data.toString());
          //       switch (data['operation']) {
          //         case 'get-user-groups':
          //           //Set joined groups
          //           joinedGroups = List.generate(data['response'].length,
          //               (index) => Group.fromJson(data['response'][index]));
          //           break;
          //         case 'get-group-by-name':
          //           //Set groups found by search
          //           searchedGroups = List.generate(data['response'].length,
          //               (index) => Group.fromJson(data['response'][index]));
          //           break;
          //         default:
          //       }
          //       if (joinedGroups != null && joinedGroups!.isNotEmpty) {
          //         return ListView.builder(
          //           shrinkWrap: true,
          //           itemBuilder: (context, index) {
          //             return ListTile(
          //               title: Text(joinedGroups![index].name),
          //               leading: CircleAvatar(
          //                   child: Text(joinedGroups![index].name[0])),
          //               trailing: const Icon(Icons.arrow_forward),
          //               onTap: () {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => GroupChannelSelect(
          //                       connection: widget.connection,
          //                       user: widget.user,
          //                       group: joinedGroups![index],
          //                       controller: widget.controller,
          //                     ),
          //                   ),
          //                 );
          //               },
          //             );
          //           },
          //           itemCount: joinedGroups!.length,
          //         );
          //       } else {
          //         return Text(
          //           "You haven't joined any groups yet! Select the magnifying glass to find a group to join, or create one with the plus!",
          //           style: TextStyle(
          //               fontSize: 20,
          //               color: Theme.of(context).colorScheme.primaryContainer),
          //         );
          //       }
          //     }

          //     return CircularProgressIndicator(
          //       color: Theme.of(context).colorScheme.primary,
          //     );
          //   },
          // ),
          //],
          //),
          ),
    );
  }
}
