import 'package:json_annotation/json_annotation.dart';

part 'request.g.dart';

@JsonSerializable()
class Request{
  final String operation;
  final String service;
  final Map<String, dynamic> data;

  Request({required this.operation, required this.service, required this.data});

  factory Request.fromJson(Map<String, dynamic> json) => _$RequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestToJson(this);
}