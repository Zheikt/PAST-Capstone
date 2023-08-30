import 'package:json_annotation/json_annotation.dart';
import 'package:past_client/classes/member.dart';
import 'package:past_client/classes/role.dart';

part 'group.g.dart';

@JsonSerializable()
class Group{
  final String id;
  String name;
  List<Map<String,String>> channels; //[{'c-xxxxxx': 'general'}]
  List<Member> members;
  Set<Role> availableRoles;
  //Queue queue;
  //List<GroupEvents> events;
  Map<String, dynamic> defaultStatBlock;

  Group({required this.id, required this.name, required this.channels, required this.members, required this.availableRoles, required this.defaultStatBlock});

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);
}