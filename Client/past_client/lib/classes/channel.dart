
import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel{
  final String id;
  String name;
  List<String> messages;
  List<String> roleRestrictions;
  List<String> blacklist;

  Channel({required this.id, required this.name, required this.messages, required this.roleRestrictions, required this.blacklist});

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}