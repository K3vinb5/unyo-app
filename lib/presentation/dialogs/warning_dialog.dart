import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';

class WarningDialog extends StatelessWidget {
  final double width;
  final double height;
  final String title;

  const WarningDialog({super.key, required this.width, required this.height, required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 24.0.h),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 15.h),
              DarkUnyoButton(
                text: "Confirm",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
