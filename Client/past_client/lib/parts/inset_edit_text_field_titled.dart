import 'package:flutter/material.dart';

class TitledInsetEditTextField extends StatefulWidget {
  final TextEditingController textController;
  final String title;
  final bool isToggleable;
  final double titleSize;

  const TitledInsetEditTextField(
      {super.key, required this.textController, required this.title, this.isToggleable = true, this.titleSize = 14});

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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 3),
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.grey.shade300, fontSize: widget.titleSize),
          ),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: TextField(
            controller: widget.textController,
            readOnly: !isEdit && widget.isToggleable,
            decoration: InputDecoration(
              suffixIcon: widget.isToggleable ? IconButton(
                onPressed: () => setState(() {
                  isEdit = !isEdit;
                }),
                icon: Icon(isEdit ? Icons.edit_off : Icons.edit),
                color:
                    Theme.of(context).colorScheme.inversePrimary.withAlpha(180),
              ) : null,
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
