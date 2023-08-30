// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      id: json['id'] as String,
      name: json['name'] as String,
      channels: (json['channels'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      members: (json['members'] as List<dynamic>)
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableRoles: (json['availableRoles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toSet(),
      defaultStatBlock: json['defaultStatBlock'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'channels': instance.channels,
      'members': instance.members,
      'availableRoles': instance.availableRoles.toList(),
      'defaultStatBlock': instance.defaultStatBlock,
    };
