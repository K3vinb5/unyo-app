import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/application/cubits/tabs_cubit.dart';
import 'package:unyo/domain/entities/user/user.dart' show User;
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/styled/user_option_drawer_selection.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

class UserOptionsDrawer extends StatefulWidget {
  const UserOptionsDrawer({super.key, required this.cubit, required this.loggedUser});

  final User loggedUser;
  final TabsCubit cubit;

  @override
  State<UserOptionsDrawer> createState() => _UserOptionsDrawerState();
}

class _UserOptionsDrawerState extends State<UserOptionsDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: 500.w,
            height: 220.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: ColorScheme.of(context).secondary.withValues(alpha: 0.7),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0.w, vertical: 20.0.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: UnyoNetworkImage(
                          url: widget.loggedUser.avatarImage,
                          fit: BoxFit.cover,
                          borderRadius: 27,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              widget.loggedUser.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Text(
                              TextUtils.capitalize(widget.loggedUser.settings.userService.name),
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 35.h),
                  UserOptionDrawerSelection(
                      text: "View Profile",
                      icon: Icons.person_rounded,
                      onPressed: widget.cubit.openUserProfileDialog
                  ),
                  SizedBox(height: 10.h),
                  UserOptionDrawerSelection(
                      text: "Logout",
                      icon: Icons.logout_rounded,
                      onPressed: () {
                        widget.cubit.logoutUser();
                        Navigator.of(context).pop();
                      }
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
