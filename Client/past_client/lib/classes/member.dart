import 'package:json_annotation/json_annotation.dart';

import 'package:past_client/classes/role.dart';

part 'member.g.dart';

@JsonSerializable()
class Member{
  final String userId;
  String nickname;
  List<String> roles;

  Member({required this.userId, required this.nickname, required this.roles});

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
  Map<String, dynamic> toJson() => _$MemberToJson(this);
}