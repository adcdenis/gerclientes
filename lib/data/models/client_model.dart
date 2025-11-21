import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

@freezed
class Client with _$Client {
  const factory Client({
    int? id,
    required String name,
    String? user,
    String? email,
    String? phone,
    required DateTime dueDate,
    String? observation,
    int? serverId,
    int? planId,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
