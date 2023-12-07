import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final String senderName;
  final List<int> colorTriple;
  final int timestamp;
  final String content;

  const MessageTile({
    super.key,
    required this.senderName,
    required this.timestamp,
    required this.content,
    this.colorTriple = const [0, 0, 0],
  });

  @override
  Widget build(BuildContext context) {
    // log(Theme.of(context).colorScheme.inversePrimary.toString());
    // log(Theme.of(context).colorScheme.primaryContainer.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$senderName - ${DateFormat('MM/dd/yyyy kk:mm').format(DateTime.fromMillisecondsSinceEpoch(timestamp))}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(
                      255,
                      colorTriple[0],
                      colorTriple[1],
                      colorTriple[2],
                    ),
                  ),
                  textAlign: TextAlign.start,
                ),
                Text(
                  content,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primaryContainer//Color.fromARGB(
                    //     Theme.of(context).colorScheme.inversePrimary.alpha,
                    //     Theme.of(context).colorScheme.inversePrimary.red + 20,
                    //     Theme.of(context).colorScheme.inversePrimary.green + 20,
                    //     Theme.of(context).colorScheme.inversePrimary.blue + 20,
                    //     ),
                  ),
                  textAlign: TextAlign.start,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
