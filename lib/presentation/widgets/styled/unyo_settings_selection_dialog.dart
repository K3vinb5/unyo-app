import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnyoSettingsSelectionDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? imageUrl;
  final void Function() openDialog;

  const UnyoSettingsSelectionDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.question_mark_rounded,
    this.imageUrl,
    required this.openDialog,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openDialog,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 75,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                    ),
                    child:
                        imageUrl == null
                            ? Icon(icon, color: ColorScheme.of(context).tertiary)
                            : Image.network(imageUrl!),
                  ),
                  const SizedBox(width: 18.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(description, style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.checklist_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
