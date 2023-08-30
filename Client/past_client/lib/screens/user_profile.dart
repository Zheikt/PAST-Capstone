import 'package:flutter/material.dart';

import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/toggleable_edit_text_field.dart';
import 'package:past_client/parts/editable_stat_display.dart';

import 'dart:developer';

class UserProfile extends StatefulWidget {
  final User user;
  final WSConnector connection;

  const UserProfile({super.key, required this.user, required this.connection});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    emailController = TextEditingController(text: widget.user.email);
    log(widget.user.toJson().toString());
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ToggleableEditTextForm(initialValue: widget.user.username),
            ToggleableEditTextForm(initialValue: widget.user.email),
            widget.user.stats.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      return EditableStatDisplay(
                          statBlock: widget.user.stats[index],
                          connection: widget.connection,
                          userId: widget.user.id);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: widget.user.stats.length,
                  )
                : const Text('No Statistics'),
            widget.user.groupIds.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      return Text(widget.user.groupIds[index]);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: widget.user.stats.length,
                  )
                : const Text('Not a member of any groups'),
          ],
        ),
      ),
    );
  }
}
