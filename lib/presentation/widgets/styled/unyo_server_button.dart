import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/domain/entities/extension/video.dart' as ext;
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

class UnyoServerButton extends StatelessWidget {
  final ext.Video videoServer;
  final void Function()? onPressed;

  const UnyoServerButton({super.key, required this.videoServer, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return UnyoInkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.grey.withValues(alpha: 0.3),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 16.0.w, right: 16.0.w, top: 16.0.h, bottom: 8.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        videoServer.quality,
                        maxLines: 12,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Icon(
                            RegExp(r'(720|1080)[pP]?').hasMatch(videoServer.quality)
                                ? Icons.hd
                                : Icons.sd,
                            color: ColorScheme.of(context).tertiary,
                          ),
                          IconButton(
                            onPressed: () {},
                            color: ColorScheme.of(context).tertiary,
                            iconSize: 22,
                            icon: const Icon(Icons.star_border_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 15,),
              Icon(Icons.play_circle_outline_rounded, size: 40.h.clamp(35, 45)),
            ],
          ),
        ),
      ),
    );
  }
}
