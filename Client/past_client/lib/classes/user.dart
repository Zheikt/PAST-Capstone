import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User{
  final String id;
  final String username;
  final String email;
  final List<Map<String, dynamic>> stats;
  final List<String> groupIds;

  const User({required this.id, required this.username, required this.email, required this.stats, required this.groupIds});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}