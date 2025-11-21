import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class Server with _$Server {
  const factory Server({
    int? id,
    required String name,
  }) = _Server;

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
}
