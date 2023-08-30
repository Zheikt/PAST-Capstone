// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      messages:
          (json['messages'] as List<dynamic>).map((e) => e as String).toList(),
      roleRestrictions: (json['roleRestrictions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      blacklist:
          (json['blacklist'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'messages': instance.messages,
      'roleRestrictions': instance.roleRestrictions,
      'blacklist': instance.blacklist,
    };
