//External dependencies
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/core/enums/login_card_type.dart';

//Internal dependencies
import 'package:unyo/domain/entities/user/user.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState implements HasEffects{
  const factory LoginState({
    required List<User> availableUsers,
    required LoginCardType selectedLoginCard,
    required bool isLoading,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _LoginState;

  const LoginState._();

  @override
  List<AppEffect> get stateEffects => effects;
}
