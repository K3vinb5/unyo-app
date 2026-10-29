// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 List<User> get availableUsers; LoginCardType get selectedLoginCard; bool get isLoading; List<AppEffect> get effects;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&const DeepCollectionEquality().equals(other.availableUsers, availableUsers)&&(identical(other.selectedLoginCard, selectedLoginCard) || other.selectedLoginCard == selectedLoginCard)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.effects, effects));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(availableUsers),selectedLoginCard,isLoading,const DeepCollectionEquality().hash(effects));

@override
String toString() {
  return 'LoginState(availableUsers: $availableUsers, selectedLoginCard: $selectedLoginCard, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 List<User> availableUsers, LoginCardType selectedLoginCard, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? availableUsers = null,Object? selectedLoginCard = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_self.copyWith(
availableUsers: null == availableUsers ? _self.availableUsers : availableUsers // ignore: cast_nullable_to_non_nullable
as List<User>,selectedLoginCard: null == selectedLoginCard ? _self.selectedLoginCard : selectedLoginCard // ignore: cast_nullable_to_non_nullable
as LoginCardType,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self.effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<User> availableUsers,  LoginCardType selectedLoginCard,  bool isLoading,  List<AppEffect> effects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.availableUsers,_that.selectedLoginCard,_that.isLoading,_that.effects);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<User> availableUsers,  LoginCardType selectedLoginCard,  bool isLoading,  List<AppEffect> effects)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.availableUsers,_that.selectedLoginCard,_that.isLoading,_that.effects);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<User> availableUsers,  LoginCardType selectedLoginCard,  bool isLoading,  List<AppEffect> effects)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.availableUsers,_that.selectedLoginCard,_that.isLoading,_that.effects);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState extends LoginState {
  const _LoginState({required final  List<User> availableUsers, required this.selectedLoginCard, required this.isLoading, final  List<AppEffect> effects = const <AppEffect>[]}): _availableUsers = availableUsers,_effects = effects,super._();
  

 final  List<User> _availableUsers;
@override List<User> get availableUsers {
  if (_availableUsers is EqualUnmodifiableListView) return _availableUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableUsers);
}

@override final  LoginCardType selectedLoginCard;
@override final  bool isLoading;
 final  List<AppEffect> _effects;
@override@JsonKey() List<AppEffect> get effects {
  if (_effects is EqualUnmodifiableListView) return _effects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_effects);
}


/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&const DeepCollectionEquality().equals(other._availableUsers, _availableUsers)&&(identical(other.selectedLoginCard, selectedLoginCard) || other.selectedLoginCard == selectedLoginCard)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._effects, _effects));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_availableUsers),selectedLoginCard,isLoading,const DeepCollectionEquality().hash(_effects));

@override
String toString() {
  return 'LoginState(availableUsers: $availableUsers, selectedLoginCard: $selectedLoginCard, isLoading: $isLoading, effects: $effects)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 List<User> availableUsers, LoginCardType selectedLoginCard, bool isLoading, List<AppEffect> effects
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? availableUsers = null,Object? selectedLoginCard = null,Object? isLoading = null,Object? effects = null,}) {
  return _then(_LoginState(
availableUsers: null == availableUsers ? _self._availableUsers : availableUsers // ignore: cast_nullable_to_non_nullable
as List<User>,selectedLoginCard: null == selectedLoginCard ? _self.selectedLoginCard : selectedLoginCard // ignore: cast_nullable_to_non_nullable
as LoginCardType,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,effects: null == effects ? _self._effects : effects // ignore: cast_nullable_to_non_nullable
as List<AppEffect>,
  ));
}


}

// dart format on
