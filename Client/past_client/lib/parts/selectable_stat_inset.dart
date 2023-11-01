import 'package:flutter/material.dart';
import 'package:past_client/classes/user.dart';
import 'package:past_client/classes/ws_connector.dart';
import 'package:past_client/parts/editable_stat_display.dart';

class SelectableStatInsetDisplay extends StatefulWidget {
  final User user;
  final WSConnector connection;

  const SelectableStatInsetDisplay(
      {super.key, required this.user, required this.connection});

  @override
  State<SelectableStatInsetDisplay> createState() =>
      _SelectableStatInsetDisplayState();
}

class _SelectableStatInsetDisplayState
    extends State<SelectableStatInsetDisplay> {
  late Map<String, dynamic> selectedStats;
  late int selectionIndex;
  late List<EditableStatDisplay> statWidgets;

  @override
  void initState() {
    int largestIndex = 0;
    for (int ind = 1; ind < widget.user.stats.length; ind++) {
      if (widget.user.stats[ind]['stats'].length >
          widget.user.stats[largestIndex]['stats'].length) {
        largestIndex = ind;
      }
    }
    selectionIndex = largestIndex;
    selectedStats = widget.user.stats[selectionIndex]['stats'];
    statWidgets = List.generate(
      widget.user.stats.length,
      (index) => EditableStatDisplay(
        statBlock: widget.user.stats[index]['stats'],
        connection: widget.connection,
        userId: widget.user.id,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Container(
            // decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.inverseSurface),
            child: DropdownMenu<String>(
              inputDecorationTheme: InputDecorationTheme(
                border: InputBorder.none,
                fillColor: Theme.of(context).colorScheme.inverseSurface,
                filled: true,
              ),
              width: MediaQuery.of(context).size.width * 0.4,
              dropdownMenuEntries: List.generate(
                widget.user.stats.length,
                (index) => DropdownMenuEntry(
                    value: widget.user.stats[index]['groupName'],
                    label: widget.user.stats[index]['groupName']),
              ),
              initialSelection: widget.user.stats[selectionIndex]['groupName'],
              label: const Text(
                "Group Stat Block",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onSelected: (String? groupName) {
                setState(
                  () {
                    selectedStats = widget.user.stats
                        .where((element) => element['groupName'] == groupName)
                        .first['stats'];
                    selectionIndex = widget.user.stats.indexWhere(
                        (element) => element['groupName'] == groupName);
                  },
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: statWidgets[selectionIndex],
        ),
      ],
    );
  }
}
