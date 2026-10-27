import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'calendar_state.freezed.dart';

@freezed
abstract class CalendarState with _$CalendarState implements HasEffects{
  const factory CalendarState({
    required Map<String, List<Anime>> animeCalendarReleases,
    required User loggedUser,
    required bool isLoading,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _CalendarState;

  const CalendarState._();

  @override
  List<AppEffect> get stateEffects => effects;
}