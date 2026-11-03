//External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

//Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/application/states/login_state.dart';
import 'package:unyo/core/i18n/locale_switcher.dart';
import 'package:unyo/core/services/effects/app_effect_handler.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/text/texts.dart';
import 'package:unyo/core/di/locator.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: const _LoginListener(),
    );
  }
}

class _LoginListener extends StatelessWidget {
  const _LoginListener();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.effects.isNotEmpty) {
          sl<AppEffectHandler>().handleEffects(
            context,
            state.effects,
            context.read<LoginCubit>().clearEffects,
          );
        }
      },
      child: const SkeletonScope(child: _LoginView()),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late final TextEditingController loginTextFieldController;

  @override
  void initState() {
    super.initState();
    loginTextFieldController = TextEditingController();
    context.read<LoginCubit>().fetchAllUsers();
  }

  @override
  void dispose() {
    super.dispose();
    loginTextFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 15),
            TextDisplayLarge(text: context.tr("dialog_select_user")),
            SizedBox(height: 40.h),
            SizedBox(
              height: 250.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (state.isLoading)
                      // Three placeholders, deliberately not one per user: the
                      // avatar row is exactly the user list, and that list only
                      // exists inside the three user sources (two Hive boxes
                      // opened by the fetch itself, plus a stubbed local repo).
                      // There is no count to read before the fetch settles, so
                      // the placeholder keeps the shape of a small account list
                      // instead of guessing a number (WP #119 round 4).
                      ...List.generate(
                        3,
                        // Mirrors UserAvatar: 160.h circle + name, inside the
                        // 250.h avatar row of the real screen.
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                          child: ListTileSkeleton(
                            height: 250.h,
                            leadingSize: 160.h,
                            titleWidth: 120,
                            vertical: true,
                          ),
                        ),
                      )
                    else
                      ...state.availableUsers.map(
                            (user) => UserAvatar(
                              user: user,
                              onPressed: () async {
                                // WP #124 decision 1: the pre-login UI runs in the
                                // OS locale. Selecting a user flips the app to that
                                // user's stored language before the route changes.
                                await applyUiLanguage(context, user.settings.language);
                                if (!context.mounted) return;
                                await context.read<LoginCubit>().loginUser(user, context);
                              },
                            ),
                      ),
                    AddUserAvatar(onPressed: () => context.read<LoginCubit>().initiateAccountCreation(context)),
                    // Display existing users
                  ],
                ),
              ),
            ),
            const Spacer(flex: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(30.0.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const TextHeadlineSmall(text: "Unyo revamped! by K3vinb5"),
                    const BrandMark(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
