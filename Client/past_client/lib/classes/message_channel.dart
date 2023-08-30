import 'package:json_annotation/json_annotation.dart';
import 'package:past_client/classes/member.dart';
import 'package:past_client/classes/message.dart';
import 'package:past_client/classes/role.dart';

part 'message_channel.g.dart';

@JsonSerializable()
class MessageChannel{
  late List<Message> messages;
  final String id;
  String name;
  late List<Role> roleRestrictions;
  late List<Member> blacklist;

  MessageChannel({required this.id, required this.name, required this.messages, required  this.blacklist, required this.roleRestrictions});

  factory MessageChannel.fromJson(Map<String, dynamic> json) => _$MessageChannelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageChannelToJson(this);
}