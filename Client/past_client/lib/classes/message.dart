import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message{
  final String id;
  String content;
  String sender;
  String recipient;
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  Message({required this.id, required this.content, required this.sender, required this.recipient});
  
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}