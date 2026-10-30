// External dependencies
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/cubits/error_copy_mapper.dart';
import 'package:unyo/application/effects/app_effects.dart';

class _TestState implements HasEffects {
  const _TestState(this.effects);

  final List<AppEffect> effects;

  @override
  List<AppEffect> get stateEffects => effects;
}

class _TestCubit extends Cubit<_TestState> with EffectMixin<_TestState> {
  _TestCubit() : super(const _TestState(<AppEffect>[]));

  @override
  final Logger logger = Logger(level: Level.off);

  @override
  _TestState copyStateWithEffects(_TestState state, List<AppEffect> effects) => _TestState(effects);
}

void main() {
  group('EffectMixin.handleError', () {
    test('shows classified copy, never the raw exception text', () {
      final _TestCubit cubit = _TestCubit();
      addTearDown(cubit.close);

      cubit.handleError(
        "Error fetching Anime Info from selected extension: LateInitializationError: "
        "Field '_jniSenderPort@636075973' has not been initialized.",
        stackTrace: StackTrace.current,
      );

      final ShowSnackbarEffect effect = cubit.state.stateEffects.whereType<ShowSnackbarEffect>().single;
      expect(effect.title, ErrorCopyMapper.genericTitle);
      expect(effect.message, ErrorCopyMapper.genericMessage);
      expect(effect.message.contains('LateInitializationError'), isFalse);
      expect(effect.message.contains('Exception'), isFalse);
    });

    test('shows connectivity copy for an HTTP server failure', () {
      final _TestCubit cubit = _TestCubit();
      addTearDown(cubit.close);

      cubit.handleError(
        'Error fetching Alternative Image:',
        responseBody: 'Server error',
      );

      final ShowSnackbarEffect effect = cubit.state.stateEffects.whereType<ShowSnackbarEffect>().single;
      expect(effect.title, ErrorCopyMapper.connectivityTitle);
      expect(effect.message, ErrorCopyMapper.connectivityMessage);
    });
  });
}
