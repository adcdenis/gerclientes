// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  user: json['user'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  dueDate: DateTime.parse(json['dueDate'] as String),
  observation: json['observation'] as String?,
  serverId: (json['serverId'] as num?)?.toInt(),
  planId: (json['planId'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user': instance.user,
      'email': instance.email,
      'phone': instance.phone,
      'dueDate': instance.dueDate.toIso8601String(),
      'observation': instance.observation,
      'serverId': instance.serverId,
      'planId': instance.planId,
    };
