import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_textfield.dart';

class TextFieldDialog extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final String hint;
  final void Function(String?) onSubmitted;

  const TextFieldDialog({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  String? currentValue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.0.h),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 5.h,),
              Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              UnyoTextfield(
                hint: widget.hint,
                label: null,
                width: widget.width * 0.8,
                debounceMilliseconds: 0,
                onChange: (newValue) {
                  setState(() {
                    currentValue = newValue;
                  });
                },
              ),
              SizedBox(height: 10.h),
              DarkUnyoButton(
                text: "Confirm",
                onPressed: () {
                  widget.onSubmitted(currentValue);
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
