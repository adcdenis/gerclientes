import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    int? id,
    required String name,
    required double value,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
