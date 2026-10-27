//External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';

//Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/application/states/login_state.dart';
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
            TextDisplayLarge(text: context.tr("select_user")),
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
                      ...List.generate(
                        3,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: ListTileSkeleton(
                            height: 200,
                            leadingSize: 160,
                            titleWidth: 120,
                            vertical: true,
                          ),
                        ),
                      )
                    else
                      ...state.availableUsers.map(
                            (user) => UserAvatar(user: user, onPressed: () => context.read<LoginCubit>().loginUser(user, context)),
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
                    Image.asset("assets/logo.png", scale: 2.5),
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
