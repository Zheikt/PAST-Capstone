import 'package:flutter/material.dart';

class CreateStat extends StatefulWidget
{
  final TextEditingController keyController;
  final TextEditingController valueContoller;

  const CreateStat({super.key, required this.keyController, required this.valueContoller});

  @override
  State<CreateStat> createState() => _CreateStatState();
}

class _CreateStatState extends State<CreateStat>{
  Type statType = String; //int, String, bool, double

  Widget build(BuildContext context){
    return const Text("Not Yet Implemented");
  }
}