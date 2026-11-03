import 'package:material_ui/material_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/i18n/app_locales.dart';

/// The settings row for WP #124's UI language picker.
///
/// Rows are [AppLocale.nativeName] (primary, in the locale's own language) plus
/// [AppLocale.englishName] (secondary, always English), and every non-English
/// row carries the "AI translated" badge required by decision 8. A "System
/// default" entry sits at the top and maps to the [kSystemLanguage] sentinel,
/// which makes the app follow the OS locale again.
///
/// Deliberately its own widget rather than a mode on
/// `UnyoSettingsSelectionDropdown`: the stock dropdown renders one plain string
/// per entry and one of these 29 rows is not a plain string.
class UnyoLanguageDropdown extends StatefulWidget {
  const UnyoLanguageDropdown({
    super.key,
    required this.title,
    required this.description,
    required this.selectedCode,
    required this.onSelected,
  });

  final String title;
  final String description;

  /// Current `Settings.language` value. `''` selects "System default".
  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  State<UnyoLanguageDropdown> createState() => _UnyoLanguageDropdownState();
}

class _UnyoLanguageDropdownState extends State<UnyoLanguageDropdown> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _labelFor(widget.selectedCode));
  }

  @override
  void didUpdateWidget(covariant UnyoLanguageDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCode != widget.selectedCode) {
      _controller.text = _labelFor(widget.selectedCode);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _labelFor(String code) {
    if (code == kSystemLanguage) return context.tr('settings_language_system_default');
    return appLocaleForCode(code)?.nativeName ?? context.tr('settings_language_system_default');
  }

  @override
  Widget build(BuildContext context) {
    final Color tertiary = ColorScheme.of(context).tertiary;
    return Container(
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
                  child: Icon(Icons.language_rounded, color: tertiary),
                ),
                const SizedBox(width: 18.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      widget.description,
                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 240.w,
              child: DropdownMenu<String>(
                key: const ValueKey('language-dropdown'),
                width: 240.w,
                controller: _controller,
                enableFilter: true,
                onSelected: (String? code) {
                  if (code == null) return;
                  widget.onSelected(code);
                },
                leadingIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(Icons.search_rounded, color: tertiary.withValues(alpha: 0.7)),
                ),
                trailingIcon: Icon(Icons.arrow_drop_down, color: tertiary.withValues(alpha: 0.7)),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    ColorScheme.of(context).secondary.withValues(alpha: 0.8),
                  ),
                  maximumSize: WidgetStatePropertyAll(Size(240.w, 360)),
                ),
                label: Text(
                  context.tr('settings_language_label'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: ColorScheme.of(context).primary, width: 3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    borderSide: BorderSide(color: tertiary.withValues(alpha: 0.8), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry<String>(
                    value: kSystemLanguage,
                    label: context.tr('settings_language_system_default'),
                    labelWidget: _entryRow(
                      context,
                      nativeName: context.tr('settings_language_system_default'),
                      englishName: null,
                      aiTranslated: false,
                    ),
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                    ),
                  ),
                  for (final AppLocale l in kAppLocales)
                    DropdownMenuEntry<String>(
                      value: l.code,
                      label: l.nativeName,
                      labelWidget: _entryRow(
                        context,
                        nativeName: l.nativeName,
                        englishName: l.englishName,
                        aiTranslated: l.isAiTranslated,
                      ),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryRow(
    BuildContext context, {
    required String nativeName,
    required String? englishName,
    required bool aiTranslated,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nativeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                if (englishName != null && englishName != nativeName)
                  Text(
                    englishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.9)),
                  ),
              ],
            ),
          ),
          if (aiTranslated) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.orange.withValues(alpha: 0.22),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.55)),
              ),
              child: Text(
                context.tr('settings_language_ai_translated'),
                style: const TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
