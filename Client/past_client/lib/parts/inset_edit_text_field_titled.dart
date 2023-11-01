import 'package:flutter/material.dart';

class TitledInsetEditTextField extends StatefulWidget {
  final TextEditingController textController;
  final String title;

  const TitledInsetEditTextField(
      {super.key, required this.textController, required this.title});

  @override
  State<TitledInsetEditTextField> createState() =>
      _TitledInsetEditTextFieldState();
}

// class _StackLayoutDelegate extends MultiChildLayoutDelegate{
//   @override
//   void performLayout(Size size){
//     Size titleSize = layoutChild("title", BoxConstraints.loose(size));
//     positionChild("title", Offset())
//   }

//   @override
//   bool shouldRelayout(_StackLayoutDelegate oldDelegate){
//     return false;
//   }
// }

class _TitledInsetEditTextFieldState extends State<TitledInsetEditTextField> {
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.grey.shade300),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextField(
            controller: widget.textController,
            readOnly: !isEdit,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () => setState(() {
                  isEdit = !isEdit;
                }),
                icon: Icon(isEdit ? Icons.edit_off : Icons.edit),
                color:
                    Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.inverseSurface,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        )
      ],
    );
  }
}
