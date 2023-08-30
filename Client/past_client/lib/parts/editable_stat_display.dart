import 'package:flutter/material.dart';
import 'package:past_client/classes/request.dart';
import 'package:past_client/classes/ws_connector.dart';

class EditableStatDisplay extends StatefulWidget {
  final Map<String, dynamic> statBlock;
  final WSConnector connection;
  final String userId;
  
  const EditableStatDisplay({super.key, required this.statBlock, required this.connection, required this.userId});

  @override
  State<EditableStatDisplay> createState() => _EditableStatDisplayState();
}

class _EditableStatDisplayState extends State<EditableStatDisplay> {
  late List<TextEditingController> controllers;
  bool canEdit = false;

  _EditableStatDisplayState() {
    controllers = List.generate(widget.statBlock.length,
        (index) => widget.statBlock['stats'].values.elementAtOrNull(index));
  }

  @override
  void initState(){
    super.initState();
    controllers = List.generate(widget.statBlock.length,
        (index) => widget.statBlock['stats'].values.elementAtOrNull(index));
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void submitChanges() {
    bool needsUpdate = findChanges();

    if(needsUpdate){
      //Update
      widget.connection.sendMessage(Request(operation: 'edit-stats', service: 'user', data: {
        "userId": widget.userId,
        "groupId": widget.statBlock['groupId'],
        "stats": widget.statBlock['stats']
      }));
    }
  }

  bool findChanges(){
    bool changed = false;
    for (int index = 0; index < controllers.length; index++) {
      dynamic value = widget.statBlock.values.elementAt(index);
      if (value is String) {
        if(value != controllers[index].text){
          changed == true;
        }
      } else if (value is int) {
        int? parsedVal = int.tryParse(controllers[index].text);
        if(parsedVal == null){
          return false;
        }
        if(value != parsedVal){
          changed == true;
        }
      } else if (value is double) {
        double? parsedVal = double.tryParse(controllers[index].text);
        if(parsedVal == null){
          return false;
        }
        if(value != parsedVal){
          changed == true;
        }
      } else if(value is bool) {
        bool? parsedVal = bool.tryParse(controllers[index].text);
        if(parsedVal == null){
          return false;
        }
        if(value != parsedVal){
          changed == true;
        }
      }
    }

    return changed;
  }

  void changeEditState() {
    setState(() {
      canEdit = !canEdit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      body: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget.statBlock['groupName']),
              ListView.builder(itemBuilder: ((context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.statBlock.keys.elementAt(index)),
                    const Text(" : "),
                    TextField(
                        controller: controllers[index], readOnly: !canEdit)
                  ],
                );
              })),
              ElevatedButton(
                  onPressed: canEdit ? () => submitChanges : changeEditState,
                  child: canEdit
                      ? const Text('Submit Changes')
                      : const Text('Edit Stats'))
            ],
          ),
        ),
      ),
    );
  }
}
