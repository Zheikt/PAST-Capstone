import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:past_client/classes/channel.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/message_channel.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/role.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/screens/create_channel_dialog.dart';
import 'package:past_client/screens/group_message_channel.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';

class GroupChannelSelect extends StatefulWidget {
  final WSConnector connection;
  final User user;
  final Group group;
  final StreamController controller;

  const GroupChannelSelect({
    super.key,
    required this.connection,
    required this.user,
    required this.group,
    required this.controller,
  });

  @override
  State<GroupChannelSelect> createState() => _GroupChannelSelectState();
}

class _GroupChannelSelectState extends State<GroupChannelSelect> {
  late List<Channel> channels = [];
  bool canRename = false;
  bool canAddDeleteChannel = false;

  @override
  void initState() {
    super.initState();
    widget.connection.sendMessage(Request(
        operation: 'get-group-channels',
        service: 'message',
        data: {'channelIds': widget.group.channels}));

    List<String> memberRoles = widget.group.members
        .firstWhere((element) => element.userId == widget.user.id)
        .roles;
    canRename = false;
    canAddDeleteChannel = false;
    for (var element in memberRoles) {
      Role role = widget.group.availableRoles
          .firstWhere((roleElem) => element == roleElem.name);
      if (role.permissions.contains('rename-channel')) {
        canRename = true;
      }
      if (role.permissions.contains('create-destroy-channel')) {
        canAddDeleteChannel = true;
      }
      if (canRename && canAddDeleteChannel) {
        break;
      }
    }
    // channels = List.generate(
    //   widget.group.channels.length,
    //   (index) => MessageChannel(
    //     id: widget.group.channels[index].keys.first,
    //     name: widget.group.channels[index].values.first,
    //     messages: [],
    //     roleRestrictions: [],
    //     blacklist: [],
    //   ),
    // );
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Select a Channel${(canRename || canAddDeleteChannel ? ' or Edit a Channel' : '')}'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const Text('Create Channel');
                }),
              );
            },
            icon: const Icon(Icons.add_circle_sharp),
          ),
          IconButton(
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
            onPressed: () {
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
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: widget.controller.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData &&
                    snapshot.data is! List &&
                    snapshot.data != '__ping__') {
                  final data = jsonDecode(snapshot.data.toString());
                  log(data.toString());
                  switch (data['operation']) {
                    case 'get-group-channels':
                      channels = List.generate(data['response'].length,
                          (index) => Channel.fromJson(data['response'][index]));
                      break;
                    default:
                  }
                }

                if(channels.isNotEmpty){
                  return Flexible(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(channels[index].name),
                          leading: CircleAvatar(
                              child: Text(channels[index].name[0])),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupMessageChannel(
                                  user: widget.user,
                                  connection: widget.connection,
                                  channel: channels[index],
                                  controller: widget.controller,
                                  group: widget.group,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      itemCount: channels.length,
                    ),
                  );
                }

                return CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            // Flexible(
            //   child: ListView.builder(
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(channels[index].name),
            //         leading: CircleAvatar(child: Text(channels[index].name[0])),
            //         onTap: () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => GroupMessageChannel(
            //                 user: widget.user,
            //                 connection: widget.connection,
            //                 channel: channels[index],
            //                 controller: widget.controller,
            //                 group: widget.group,
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //     itemCount: channels.length,
            //   ),
            // ),
            ElevatedButton(
              onPressed: canAddDeleteChannel
                  ? () => showDialog(
                        context: context,
                        builder: (context) => CreateChannelDialog(
                            connection: widget.connection, group: widget.group, controller: widget.controller,),
                      )
                  : null,
              child: const Text('Add Channel'),
            ),
          ],
        ),
      ),
    );
  }
}
