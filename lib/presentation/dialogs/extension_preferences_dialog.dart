import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/domain/entities/extension/preference_item.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_multi_select_dropdown.dart';
import 'package:unyo/presentation/widgets/styled/unyo_textfield.dart';
import 'package:unyo/presentation/widgets/styled/unyo_toggle.dart';

class ExtensionPreferencesDialog extends StatefulWidget {
  final String pkg;
  final List<PreferenceItem> preferences;
  final void Function(Map<String, dynamic>) onSave;

  const ExtensionPreferencesDialog({
    super.key,
    required this.pkg,
    required this.preferences,
    required this.onSave,
  });

  @override
  State<ExtensionPreferencesDialog> createState() => _ExtensionPreferencesDialogState();
}

class _ExtensionPreferencesDialogState extends State<ExtensionPreferencesDialog> {
  late final Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = {
      for (final pref in widget.preferences) pref.key: pref.value,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: SizedBox(
        width: 600.w,
        height: 600.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
          child: Column(
            children: [
              const Text(
                "Extension Preferences",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.pkg,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.preferences.length,
                  itemBuilder: (context, index) {
                    final pref = widget.preferences[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.0.h, left: 16.0.w, right: 16.0.w),
                      child: _buildPreferenceField(pref),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: "Cancel",
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 12.w),
                  LightUnyoButton(
                    text: "Confirm",
                    onPressed: () {
                      widget.onSave(_values);
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

  Widget _buildPreferenceField(PreferenceItem pref) {
    switch (pref.type) {
      case 'SwitchPreferenceCompat':
        return _buildSwitchPreference(pref);
      case 'ListPreference':
        return _buildListPreference(pref);
      case 'EditTextPreference':
        return _buildEditTextPreference(pref);
      case 'MultiSelectListPreference':
        return _buildMultiSelectPreference(pref);
      default:
        return Text(
          "Unsupported preference type: ${pref.type}",
          style: const TextStyle(color: Colors.red),
        );
    }
  }

  Widget _buildSwitchPreference(PreferenceItem pref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pref.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (pref.summary != null && pref.summary!.isNotEmpty && pref.summary! != "%s") ...[
          SizedBox(height: 2.h),
          Text(
            pref.summary!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        SizedBox(height: 6.h),
        UnyoToggle(
          value: (_values[pref.key] as bool?) ?? false,
          onChanged: (value) => setState(() => _values[pref.key] = value),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildEditTextPreference(PreferenceItem pref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pref.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (pref.summary != null && pref.summary!.isNotEmpty && pref.summary! != "%s") ...[
          SizedBox(height: 2.h),
          Text(
            pref.summary!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        SizedBox(height: 6.h),
        UnyoTextfield(
          label: null,
          hint: pref.summary,
          initialValue: (_values[pref.key] as String?) ?? '',
          debounceMilliseconds: 0,
          onChange: (value) => setState(() => _values[pref.key] = value),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildListPreference(PreferenceItem pref) {
    final entries = pref.entries ?? [];
    final entryValues = pref.entryValues ?? [];
    final currentValue = (_values[pref.key] as String?) ?? '';

    // Find display label for current value
    String? selectedLabel;
    final valueIndex = entryValues.indexOf(currentValue);
    if (valueIndex >= 0 && valueIndex < entries.length) {
      selectedLabel = entries[valueIndex];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pref.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (pref.summary != null && pref.summary!.isNotEmpty && pref.summary! != "%s") ...[
          SizedBox(height: 2.h),
          Text(
            pref.summary!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        SizedBox(height: 6.h),
        UnyoDropdown(
          label: null,
          selectedValue: selectedLabel,
          reactOnCancel: true,
          children: entries,
          onPressed: (label) {
            if (label == null) {
              setState(() => _values[pref.key] = null);
              return;
            }
            final index = entries.indexOf(label);
            if (index >= 0 && index < entryValues.length) {
              setState(() => _values[pref.key] = entryValues[index]);
            }
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildMultiSelectPreference(PreferenceItem pref) {
    final entries = pref.entries ?? [];
    final entryValues = pref.entryValues ?? [];
    final currentSet = (_values[pref.key] as Set<String>?) ?? <String>{};

    // Map selected entryValues to display labels
    final selectedLabels = <String>[];
    for (final val in currentSet) {
      final index = entryValues.indexOf(val);
      if (index >= 0 && index < entries.length) {
        selectedLabels.add(entries[index]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pref.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (pref.summary != null && pref.summary!.isNotEmpty && pref.summary! != "%s") ...[
          SizedBox(height: 2.h),
          Text(
            pref.summary!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        SizedBox(height: 6.h),
        UnyoMultiSelectDropdown(
          label: null,
          children: entries,
          selectedValues: selectedLabels,
          debounceMilliseconds: 0,
          onChanged: (labels) {
            final newValues = <String>{};
            for (final label in labels) {
              final index = entries.indexOf(label);
              if (index >= 0 && index < entryValues.length) {
                newValues.add(entryValues[index]);
              }
            }
            setState(() => _values[pref.key] = newValues);
          },
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
