import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';

class UnyoMenuBar extends StatelessWidget {
  final List<UnyoMenuIcon> icons;
  final void Function() onIconTap;
  const UnyoMenuBar({super.key, required this.avatarImage, required this.onIconTap, required this.icons});

  final String avatarImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0.w, top: 15.0.h),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.softLight,
              child: Container(
                // constraints: const BoxConstraints(),
                width: 80.0,
                height: 440.0,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(40.0),
                  // backgroundBlendMode: BlendMode.softLight,
                  // color: Colors.grey.withValues(alpha: 70)
                ),
                child: Column(
                 children: [
                   const SizedBox(height: 20,),
                     Material(
                       color: Colors.transparent,
                       child: InkWell(
                         borderRadius: BorderRadius.circular(35),
                         onTap: onIconTap,
                         child: CircleAvatar(
                           radius: 27,
                           backgroundColor: Colors.transparent,
                           backgroundImage: NetworkImage(avatarImage),
                         ),
                       ),
                     ),
                   Divider(
                     height: 40.0,
                     thickness: 1.0,
                     indent: 13,
                     endIndent: 13,
                     color: Colors.grey.shade700,
                   ),
                   ...icons
                 ],
                )
              ),
            ),
          ),
        ),
      ),
    );
  }
}
