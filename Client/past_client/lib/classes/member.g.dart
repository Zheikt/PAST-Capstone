// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'roles': instance.roles,
    };
