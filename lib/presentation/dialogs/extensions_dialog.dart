import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_textfield.dart';

class ExtensionsSettingsDialog extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final List<String> currentRepositoriesUrls;
  final void Function(List<String>) onSubmitted;

  const ExtensionsSettingsDialog({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.currentRepositoriesUrls,
    required this.onSubmitted,
  });

  @override
  State<ExtensionsSettingsDialog> createState() => _ExtensionsSettingsDialogState();
}

class _ExtensionsSettingsDialogState extends State<ExtensionsSettingsDialog> {
  late List<String> _currentRepositoriesUrls;

  @override
  void initState() {
    super.initState();
    _currentRepositoriesUrls = List.from(widget.currentRepositoriesUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 5.h),
                    Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 25.h),
                    ..._currentRepositoriesUrls.mapIndexed(
                          (index, repoUrl) =>
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      TextUtils.extractRepoName(repoUrl),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: UnyoTextfield(
                                        label: null,
                                        hint: repoUrl,
                                        debounceMilliseconds: 0,
                                        onChange: (newValue) {
                                          setState(() {
                                            _currentRepositoriesUrls[index] = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    DarkUnyoButton(
                                      text: "Remove",
                                      onPressed: () {
                                        setState(() {
                                          if (_currentRepositoriesUrls.length == 1) {
                                            return;
                                          } else {
                                            _currentRepositoriesUrls.removeAt(index);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: LightUnyoButton(text: "Add Repository", onPressed: () {
                        setState(() {
                          _currentRepositoriesUrls.add("");
                        });
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 8.w),
                  LightUnyoButton(
                    text: "Confirm",
                    onPressed: () {
                      widget.onSubmitted(_currentRepositoriesUrls);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
