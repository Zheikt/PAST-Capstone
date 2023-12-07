import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:past_client/classes/channel.dart';
import 'package:past_client/classes/group.dart';
import 'package:past_client/classes/member.dart';
import 'package:past_client/classes/message.dart';
import 'package:past_client/classes/message_channel.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/inset_edit_text_field_titled.dart';
import 'package:past_client/parts/message.dart';
import 'package:past_client/screens/group_select.dart';
import 'package:past_client/screens/start_page.dart';
import 'package:past_client/screens/user_profile.dart';
import 'package:stream_channel/stream_channel.dart';

class GroupMessageChannel extends StatefulWidget {
  final User user;
  final Channel channel;
  final WSConnector connection;
  final StreamController controller;
  final Group group;

  const GroupMessageChannel({
    super.key,
    required this.user,
    required this.channel,
    required this.connection,
    required this.controller,
    required this.group,
  });

  @override
  State<GroupMessageChannel> createState() => _GroupMessageChannelState();
}

class _GroupMessageChannelState extends State<GroupMessageChannel> {
  late List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //messages = [];
    widget.connection.sendMessage(
      Request(
        operation: 'get-channel-messages',
        service: 'message',
        data: {'messageIds': widget.channel.messages},
      ),
    );
    // messages = [
    //   Message(
    //       id: 'm-1x2y3z',
    //       content: "This is a test message",
    //       sender: 'u-123456',
    //       recipient: 'c-1m2m3m')
    // ];
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.jumpTo(_scrollController.position.minScrollExtent));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => true);
            },
            icon: const Icon(Icons.groups),
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
        title: Text(widget.channel.name),
      ),
      body: Column(
        children: [
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
                    case 'get-channel-messages':
                      messages = List.generate(
                        data['response'].length,
                        (index) => Message.fromJson(data['response'][index]),
                      );

                      break;
                    case 'create-message':
                      messages.add(Message.fromJson(data['response']));
                      List<String> userIds = List.generate(
                          widget.group.members.length,
                          (index) => widget.group.members[index].userId);
                      userIds.remove(widget.user.id);
                      widget.connection.sendMessage(
                        Request(
                          operation: 'new-message-prop',
                          service: 'wss',
                          data: {
                            'userIds': userIds,
                            'message': data['response'],
                          },
                        ),
                      );
                      break;
                    case 'new-message-prop':
                      messages.insert(0, Message.fromJson(data['message']));
                      break;
                  }
                }

                messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                messages = messages.reversed.toList();

                return Expanded(
                  child: CustomScrollView(
                    reverse: true,
                    controller: _scrollController,
                    slivers: [
                      SliverList.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          String senderNick = widget.group.members
                              .where(
                                (element) =>
                                    messages[index].sender == element.userId,
                              )
                              .first
                              .nickname;
                          // return ListTile(
                          //   title: Text(senderNick),
                          //   subtitle: Text(messages[index].content),
                          //   leading: CircleAvatar(child: Text(senderNick[0])),
                          // );
                          return MessageTile(
                            senderName: senderNick,
                            timestamp: messages[index].timestamp,
                            content: messages[index].content,
                          );
                        },
                      ),
                      SliverAppBar(
                        pinned: false,
                        stretch: true,
                        automaticallyImplyLeading: false,
                        forceMaterialTransparency: true,
                        title: Text(
                          "The start of great plans and activities in ${widget.group.name}'s ${widget.channel.name} channel!",
                          maxLines: 3,
                          softWrap: true,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          // Flexible(
          //   child: ListView.builder(
          //     controller: _scrollController,
          //     reverse: true,
          //     itemCount: messages.length,
          //     itemBuilder: (context, index) {
          //       String senderNick = widget.group.members
          //           .where(
          //             (element) => messages[index].sender == element.userId,
          //           )
          //           .first
          //           .nickname;
          //       return ListTile(
          //         title: Text(senderNick),
          //         subtitle: Text(messages[index].content),
          //         leading: CircleAvatar(child: Text(senderNick[0])),
          //       );
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                minLines: 1,
                maxLines: 5,
                validator: (value) => value!.isEmpty
                    ? "Message cannot be empty"
                    : value.trim().isEmpty
                        ? "Message cannot be only whitespace"
                        : value.length > 1024
                            ? "Message cannot exceed 1024 characters"
                            : null,
                controller: messageController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                decoration: InputDecoration(
                  helperText: " ",
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.connection.sendMessage(
                            Request(
                                operation: 'send-message',
                                service: 'message',
                                data: {
                                  'sender': widget.user.id,
                                  'recipient': widget.channel.id,
                                  'content': messageController.text
                                }),
                          );
                          // setState(() {
                          //   messages.insert(
                          //       0,
                          //       Message(
                          //           id: 'm-4l5m6n',
                          //           content: messageController.text,
                          //           sender: widget.user.id,
                          //           recipient: widget.channel.id));
                          // });
                          messageController.text = "";
                        }
                      },
                      icon: const Icon(Icons.send)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.inverseSurface,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
