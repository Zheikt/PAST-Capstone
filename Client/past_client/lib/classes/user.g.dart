// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email']['email'] as String,
      stats: (json['stats'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      groupIds:
          (json['groupIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'stats': instance.stats,
      'groupIds': instance.groupIds,
    };
