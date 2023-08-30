import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:past_client/classes/channel.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/request.dart';
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
  late List<Channel> channels;
  bool canRename = false;
  bool canAddDeleteChannel = false;

  @override
  void initState() {
    super.initState();
    widget.connection.sendMessage(Request(
        operation: 'get-user-groups',
        service: 'group',
        data: {'userId': widget.user.id}));
    canRename = widget.group.members
        .firstWhere((element) => element.userId == widget.user.id)
        .roles
        .where((element) => element.permissions.contains('rename-channel'))
        .isNotEmpty;
    canAddDeleteChannel = widget.group.members
        .firstWhere((element) => element.userId == widget.user.id)
        .roles
        .where(
            (element) => element.permissions.contains('create-destroy-channel'))
        .isNotEmpty;
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
                    snapshot.hasData) {
                  final data = jsonDecode(snapshot.data.toString())['data'];
                  switch (data['operation']) {
                    case 'get-user-groups':
                      channels = List.generate(data['response'].length,
                          (index) => Channel.fromJson(data['response'][index]));
                      break;
                    default:
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(channels[index].name),
                        leading:
                            CircleAvatar(child: Text(channels[index].name[0])),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GroupMessageChannel()));
                        },
                      );
                    },
                    itemCount: channels.length,
                  );
                }

                return CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            ElevatedButton(
              onPressed: canAddDeleteChannel
                  ? () => showDialog(
                        context: context,
                        builder: (context) => CreateChannelDialog(
                            connection: widget.connection, group: widget.group),
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
