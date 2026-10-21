import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/unyo_pill.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

class UnyoExtensionButton extends StatelessWidget {
  final void Function()? onDownloadPressed;
  final void Function()? onUpdatePressed;
  final void Function()? onDeletePressed;
  final void Function()? onSettingsPressed;
  final String iconUrl;
  final String name;
  final String lang;
  final String version;
  final int nsfw;
  final String repoUrl;

  const UnyoExtensionButton({
    super.key,
    this.onDownloadPressed,
    this.onUpdatePressed,
    required this.iconUrl,
    required this.name,
    required this.lang,
    required this.version,
    required this.nsfw,
    required this.repoUrl,
    this.onDeletePressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0.w, right: 16.0.w, bottom: 8.0.h),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withValues(alpha: 0.15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 20.w),
                ClipOval(child: Image.network(iconUrl, fit: BoxFit.fill, width: 52, height: 52)),
                SizedBox(width: 14.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        nsfw == 1
                            ? const UnyoPill(
                              text: "NFSW",
                              color: Colors.amber,
                              height: 14,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              horizontalPadding: 4,
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UnyoPill(
                          text: TextUtils.capitalize(lang),
                          color: ColorScheme.of(context).primary,
                        ),
                        const SizedBox(width: 4.0),
                        UnyoPill(
                          text: version,
                          color: ColorScheme.of(context).tertiary,
                        ),
                        const SizedBox(width: 4.0),
                        UnyoPill(
                          height: 16,
                          text: TextUtils.extractRepoName(repoUrl),
                          color: Colors.blue.harmonizeWith(ColorScheme.of(context).secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                onDownloadPressed != null
                    ? Padding(
                      padding: EdgeInsets.only(left: 10.0.w),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 1000),
                        message: "Download",
                        child: InkWell(
                          onTap: onDownloadPressed,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.download_rounded, color: ColorScheme.of(context).tertiary),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
                onUpdatePressed != null
                    ? Padding(
                      padding: EdgeInsets.only(left: 10.0.w),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 1000),
                        message: "Update",
                        child: InkWell(
                          onTap: onUpdatePressed,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.sync_rounded, color: Colors.greenAccent.withValues(alpha: 0.8)),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
                onSettingsPressed != null
                    ? Padding(
                      padding: EdgeInsets.only(left: 10.0.w),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 1000),
                        message: "Settings",
                        child: InkWell(
                          onTap: onSettingsPressed,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.settings_rounded, color: ColorScheme.of(context).tertiary),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
                onDeletePressed != null
                    ? Padding(
                      padding: EdgeInsets.only(left: 10.0.w),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 1000),
                        message: "Delete",
                        child: InkWell(
                          onTap: onDeletePressed,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.delete_rounded, color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
                SizedBox(width: 20.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
