import 'package:flutter/material.dart';

import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/inset_edit_text_field_titled.dart';
import 'package:past_client/parts/selectable_stat_inset.dart';
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

  Future<void> confirmDeleteUser() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Account Deletion"),
        content: const Text(
            "This action is irreversible. Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: deleteUser,
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  void deleteUser() {
    //request to delete user's account
    log("Delete User method");
    Navigator.of(context).pop();
    //On success, return to Register/Login
    Navigator.of(context).popUntil((route) => route.isFirst);
    //on failure, notify user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              child: TitledInsetEditTextField(
                initialValue: widget.user.username,
                title: "Username",
              ),
            ),
            const Divider(
                thickness: 1,
                indent: 4,
                endIndent: 4,
                color: Color.fromARGB(148, 144, 164, 174)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              child: TitledInsetEditTextField(
                initialValue: widget.user.email,
                title: "Email",
              ),
            ),
            const Divider(
                thickness: 1,
                indent: 4,
                endIndent: 4,
                color: Color.fromARGB(148, 144, 164, 174)),
            widget.user.stats.isNotEmpty
                ? SelectableStatInsetDisplay(
                    user: widget.user, connection: widget.connection)
                : const Text('No Statistics'),
            // widget.user.groupIds.isNotEmpty
            //     ? ListView.separated(
            //         itemBuilder: (context, index) {
            //           return Text(widget.user.groupIds[index]);
            //         },
            //         separatorBuilder: (context, index) {
            //           return const Divider();
            //         },
            //         itemCount: widget.user.stats.length,
            //       )
            //     : const Text('Not a member of any groups'),
            const Spacer(),
            ElevatedButton(
              onPressed: confirmDeleteUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
