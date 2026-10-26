import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// Opens the Unyo date picker dialog and resolves to the picked day.
///
/// This replaces material_ui's `showDatePicker` on purpose: since Flutter 3.47
/// the default `adaptiveClickable` cursor is a plain arrow on desktop, and the
/// package's picker builds its day cells internally, so they can neither be
/// themed nor wrapped. Every interactive piece here goes through [UnyoInkWell]
/// so day cells and actions show the same click cursor and hover ink as the
/// rest of the app (see OP #56).
Future<DateTime?> showUnyoDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final DateTime now = DateTime.now();
  return showDialog<DateTime>(
    context: context,
    builder:
        (context) => UnyoDatePicker(
          initialDate: initialDate ?? now,
          firstDate: firstDate ?? DateTime(now.year - 100),
          lastDate: lastDate ?? DateTime(now.year + 100),
        ),
  );
}

class UnyoDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const UnyoDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<UnyoDatePicker> createState() => _UnyoDatePickerState();
}

class _UnyoDatePickerState extends State<UnyoDatePicker> {
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const List<String> _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late DateTime _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  late DateTime? _selected = _dateOnly(widget.initialDate);

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isEnabled(DateTime day) {
    return !day.isBefore(_dateOnly(widget.firstDate)) && !day.isAfter(_dateOnly(widget.lastDate));
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  List<DateTime> _visibleDays() {
    // Monday-first grid: the 1st's weekday gives the offset of the first cell.
    //
    // Build the cells with the DateTime constructor (calendar arithmetic), not
    // Duration.add: on DST days (e.g. the Oct 25 fall-back in WEST) "+24h" is
    // shorter than a calendar day, which duplicated a date and shifted every
    // later cell — and left today unmatched for preselection (OP #56).
    final DateTime firstOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month);
    final int offset = firstOfMonth.weekday - 1;
    return List<DateTime>.generate(
      42,
      (i) => DateTime(firstOfMonth.year, firstOfMonth.month, firstOfMonth.day - offset + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UnyoInkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () => _changeMonth(-1),
                    child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.chevron_left)),
                  ),
                  Text(
                    '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  UnyoInkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () => _changeMonth(1),
                    child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.chevron_right)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final String name in _weekdayNames)
                    Expanded(
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              for (int week = 0; week < 6; week++)
                Row(
                  children: [
                    for (int weekday = 0; weekday < 7; weekday++)
                      Expanded(child: _dayCell(_visibleDays()[week * 7 + weekday])),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(text: "Cancel", maxHeight: 50, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 16),
                  LightUnyoButton(
                    text: "OK",
                    maxHeight: 50,
                    isEnabled: _selected != null && _isEnabled(_selected!),
                    onPressed: () => Navigator.of(context).pop(_selected),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    final bool inMonth = day.month == _displayedMonth.month;
    final bool enabled = inMonth && _isEnabled(day);
    final bool selected = _selected != null && day == _selected;

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: Colors.transparent,
          child: UnyoInkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: !enabled ? null : () => setState(() => _selected = day),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: enabled ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
