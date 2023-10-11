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

  @override
  void initState() {
    selectedStats = widget.user.stats[0]['stats'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownMenu<String>(
            dropdownMenuEntries: List.generate(
              widget.user.stats.length,
              (index) => DropdownMenuEntry(
                  value: widget.user.stats[index]['groupName'],
                  label: widget.user.stats[index]['groupName']),
            ),
            initialSelection: widget.user.stats[0]['groupName'],
            label: const Text("Group Stat Block"),
            onSelected: (String? groupName) {
              setState(() {
                selectedStats = widget.user.stats
                    .where((element) => element['groupName'] == groupName)
                    .first['stats'];
              });
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: EditableStatDisplay(
            statBlock: selectedStats,
            connection: widget.connection,
            userId: widget.user.id,
          ),
        ),
      ],
    );
  }
}
