import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/user.dart';

part 'extensions_state.freezed.dart';

@freezed
abstract class ExtensionsState with _$ExtensionsState implements HasEffects{
  const factory ExtensionsState({
    required User loggedUser,
    required List<Extension> installedAnimeExtensions,
    required List<Extension> installedMangaExtensions,
    required List<Extension> availableAnimeExtensions,
    required List<Extension> availableMangaExtensions,
    required bool userLoaded,
    required bool extensionsLoaded,
    @Default({}) Map<String, Extension> animeExtensionUpdates,
    @Default({}) Map<String, Extension> mangaExtensionUpdates,
    @Default(<AppEffect>[]) List<AppEffect> effects,
  }) = _ExtensionsState;

  const ExtensionsState._();

  @override
  List<AppEffect> get stateEffects => effects;
}
