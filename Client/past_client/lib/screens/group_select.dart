import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/screens/group_channel_select.dart';
import 'package:past_client/screens/group_create.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class GroupSelect extends StatefulWidget {
  final WSConnector connection;
  final User user;
  final StreamController controller;

  const GroupSelect(
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
  bool isSearch = false;
  TextEditingController searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.connection.sendMessage(Request(
        operation: 'get-user-groups',
        service: 'group',
        data: {'userId': widget.user.id}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Group!'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return CreateGroupPage(
                      connection: widget.connection, user: widget.user);
                }),
              );
            },
            icon: const Icon(Icons.add_circle_sharp),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
              });
            },
            icon: const Icon(Icons.search),
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
          if (isSearch)
            LayoutGrid(
              columnSizes: [1.fr],
              rowSizes: const [auto],
              rowGap: 10,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: TextFormField(
                    key: _formKey,
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: ElevatedButton(
                    style: const ButtonStyle(maximumSize: MaterialStatePropertyAll(Size(80, 40,))),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.connection.sendMessage(
                          Request(
                            operation: 'get-group-by-name',
                            service: 'group',
                            data: {'name': searchController.value},
                          ),
                        );
                      }
                    },
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          StreamBuilder(
            stream: widget.controller.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                final data = jsonDecode(snapshot.data.toString());
                switch (data['operation']) {
                  case 'get-user-groups':
                    joinedGroups = List.generate(data['response'].length,
                        (index) => Group.fromJson(data['response'][index]));
                    break;
                  case 'get-group-by-name':
                    searchedGroups = List.generate(data['response'].length,
                        (index) => Group.fromJson(data['response'][index]));
                    break;
                  default:
                }
                if (joinedGroups != null && joinedGroups!.isNotEmpty) {
                  return ListView.builder(
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
                        },
                      );
                    },
                    itemCount: joinedGroups!.length,
                  );
                } else {
                  return Text(
                    "You haven't joined any groups yet! Select the magnifying glass to find a group to join, or create one with the plus!",
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primaryContainer),
                  );
                }
              }

              return CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ],
      )),
    );
  }
}
