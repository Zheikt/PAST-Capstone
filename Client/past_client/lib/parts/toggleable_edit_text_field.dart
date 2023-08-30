import 'package:flutter/material.dart';

class ToggleableEditTextForm extends StatefulWidget {
  final String initialValue;

  const ToggleableEditTextForm({super.key, required this.initialValue});

  @override
  State<ToggleableEditTextForm> createState() => _ToggleableEditTextFormState();
}

class _ToggleableEditTextFormState extends State<ToggleableEditTextForm> {
  late TextEditingController textController;
  bool isEdit = false;

  @override
  void initState(){
    super.initState();
    textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      readOnly: !isEdit,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () => setState(() {
          isEdit = !isEdit;
        }), 
        icon: Icon(isEdit? Icons.edit_off : Icons.edit),
        color: Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
        ),
      ),
    );
  }
}
