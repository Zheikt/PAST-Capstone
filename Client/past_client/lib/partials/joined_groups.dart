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

class JoinedGroupsBody extends StatefulWidget {
  final User user;
  final WSConnector connection;
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

  JoinedGroupsBody(
      {super.key,
      required this.user,
      required this.connection,
      required this.controller});

  @override
  State<JoinedGroupsBody> createState() => _JoinedGroupsBodyState();
}

class _JoinedGroupsBodyState extends State<JoinedGroupsBody> {
  List<Group>? joinedGroups = null;

  @override
  void initState() {
    super.initState();
    //Use Test Data
    //joinedGroups = widget.testGroups;
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
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
              stream: widget.controller.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData &&
                    snapshot.data is! List &&
                    snapshot.data != '__ping__') {
                  final data = jsonDecode(snapshot.data.toString());
                  switch (data['operation']) {
                    case 'get-user-groups':
                      //Set joined groups
                      joinedGroups = List.generate(data['response'].length,
                          (index) => Group.fromJson(data['response'][index]));
                      break;
                    default:
                  }
                }
                if (joinedGroups == null || joinedGroups!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "You haven't joined any groups yet! Select the magnifying glass to find a group to join, or create one with the plus!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  //Replace with StreamBuilder (maybe change to LayoutGrid to mess with padding)
                  itemCount: joinedGroups!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(joinedGroups![index].name),
                        leading: CircleAvatar(
                            child: Text(joinedGroups![index].name[0])),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChannelSelect(
                                connection: widget.connection,
                                user: widget.user,
                                group: joinedGroups![index],
                                controller: widget.controller,
                              ),
                            ),
                          );
                        });
                  },
                );
              }),
        )
      ],
    );
  }
}
