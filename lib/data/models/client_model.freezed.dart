// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Client _$ClientFromJson(Map<String, dynamic> json) {
  return _Client.fromJson(json);
}

/// @nodoc
mixin _$Client {
  int? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get user => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get observation => throw _privateConstructorUsedError;
  int? get serverId => throw _privateConstructorUsedError;
  int? get planId => throw _privateConstructorUsedError;

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call({
    int? id,
    String name,
    String? user,
    String? email,
    String? phone,
    DateTime dueDate,
    String? observation,
    int? serverId,
    int? planId,
  });
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? user = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? dueDate = null,
    Object? observation = freezed,
    Object? serverId = freezed,
    Object? planId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            observation: freezed == observation
                ? _value.observation
                : observation // ignore: cast_nullable_to_non_nullable
                      as String?,
            serverId: freezed == serverId
                ? _value.serverId
                : serverId // ignore: cast_nullable_to_non_nullable
                      as int?,
            planId: freezed == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClientImplCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$ClientImplCopyWith(
    _$ClientImpl value,
    $Res Function(_$ClientImpl) then,
  ) = __$$ClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String name,
    String? user,
    String? email,
    String? phone,
    DateTime dueDate,
    String? observation,
    int? serverId,
    int? planId,
  });
}

/// @nodoc
class __$$ClientImplCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$ClientImpl>
    implements _$$ClientImplCopyWith<$Res> {
  __$$ClientImplCopyWithImpl(
    _$ClientImpl _value,
    $Res Function(_$ClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? user = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? dueDate = null,
    Object? observation = freezed,
    Object? serverId = freezed,
    Object? planId = freezed,
  }) {
    return _then(
      _$ClientImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        observation: freezed == observation
            ? _value.observation
            : observation // ignore: cast_nullable_to_non_nullable
                  as String?,
        serverId: freezed == serverId
            ? _value.serverId
            : serverId // ignore: cast_nullable_to_non_nullable
                  as int?,
        planId: freezed == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientImpl implements _Client {
  const _$ClientImpl({
    this.id,
    required this.name,
    this.user,
    this.email,
    this.phone,
    required this.dueDate,
    this.observation,
    this.serverId,
    this.planId,
  });

  factory _$ClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientImplFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  final String? user;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final DateTime dueDate;
  @override
  final String? observation;
  @override
  final int? serverId;
  @override
  final int? planId;

  @override
  String toString() {
    return 'Client(id: $id, name: $name, user: $user, email: $email, phone: $phone, dueDate: $dueDate, observation: $observation, serverId: $serverId, planId: $planId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.observation, observation) ||
                other.observation == observation) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.planId, planId) || other.planId == planId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    user,
    email,
    phone,
    dueDate,
    observation,
    serverId,
    planId,
  );

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      __$$ClientImplCopyWithImpl<_$ClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientImplToJson(this);
  }
}

abstract class _Client implements Client {
  const factory _Client({
    final int? id,
    required final String name,
    final String? user,
    final String? email,
    final String? phone,
    required final DateTime dueDate,
    final String? observation,
    final int? serverId,
    final int? planId,
  }) = _$ClientImpl;

  factory _Client.fromJson(Map<String, dynamic> json) = _$ClientImpl.fromJson;

  @override
  int? get id;
  @override
  String get name;
  @override
  String? get user;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  DateTime get dueDate;
  @override
  String? get observation;
  @override
  int? get serverId;
  @override
  int? get planId;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
