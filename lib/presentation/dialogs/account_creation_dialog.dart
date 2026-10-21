// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

// Internal dependencies
import 'package:unyo/application/cubits/login_cubit.dart';
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/text/text_display_large.dart';

import '../../application/states/login_state.dart';

class AccountCreationDialog extends StatelessWidget {
  const AccountCreationDialog(this.screenContext, {super.key, required this.cubit});

  final BuildContext screenContext;
  final LoginCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          return Dialog(
            backgroundColor: const Color.fromARGB(255, 30, 30, 30),
            child: SizedBox(
              width: 0.6.sw,
              height: 0.6.sh,
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  TextDisplayLarge(text: context.tr("sign_in_title")),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LoginCard(
                                svgPicture: SvgPicture.asset(
                                  'assets/images/anilist.svg',
                                  width: 120.w,
                                  height: 120.h,
                                ),
                                title: 'Anilist',
                                description: 'Sync your list with Anilist',
                                onTap: () => context.read<LoginCubit>().selectLoginType(LoginCardType.anilist),
                                isSelected: state.selectedLoginCard == LoginCardType.anilist,
                              ),
                              LoginCard(
                                svgPicture: SvgPicture.asset(
                                  'assets/images/myanimelist.svg',
                                  width: 120.w,
                                  height: 120.h,
                                ),
                                title: 'MyAnimeList',
                                description: 'Sync your list with MyAnimeList',
                                onTap: () => context.read<LoginCubit>().selectLoginType(LoginCardType.mal),
                                isSelected: state.selectedLoginCard == LoginCardType.mal,
                              ),
                              LoginCard(
                                svgPicture: SvgPicture.asset(
                                  'assets/images/local_account.svg',
                                  width: 130.w,
                                  height: 130.h,
                                ),
                                title: 'Local Account',
                                description: 'Offline usage, no sync',
                                onTap: () => context.read<LoginCubit>().selectLoginType(LoginCardType.local),
                                isSelected: state.selectedLoginCard == LoginCardType.local,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DarkUnyoButton(onPressed: () => context.read<LoginCubit>().closeDialogEffect(context), text: context.tr("cancel"),),
                        SizedBox(width: 15.w,),
                        LightUnyoButton(onPressed: () => context.read<LoginCubit>().attemptToCreateUser(context), text: context.tr("confirm"),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
