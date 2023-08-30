// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageChannel _$MessageChannelFromJson(Map<String, dynamic> json) =>
    MessageChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      blacklist: (json['blacklist'] as List<dynamic>)
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(),
      roleRestrictions: (json['roleRestrictions'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessageChannelToJson(MessageChannel instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'id': instance.id,
      'name': instance.name,
      'roleRestrictions': instance.roleRestrictions,
      'blacklist': instance.blacklist,
    };
