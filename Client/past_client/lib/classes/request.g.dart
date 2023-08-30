// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) => Request(
      operation: json['operation'] as String,
      service: json['service'] as String,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'operation': instance.operation,
      'service': instance.service,
      'data': instance.data,
    };
