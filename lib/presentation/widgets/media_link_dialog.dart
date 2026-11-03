import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_link_candidate.dart';
import 'package:unyo/core/services/media/media_link_proposal.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';

/// Asks the user which of the proposed metadata entries is the right one.
///
/// Shown only when the MAL-pivot chain fell through to a heuristic title search:
/// provider-field and AniZip matches are applied without asking. The dialog
/// always explains *why* it appeared (the two providers disagree) and never
/// forces a pick.
class MediaLinkDialog extends StatefulWidget {
  final MediaLinkProposal proposal;
  final void Function(MediaLinkCandidate candidate) onLink;
  final VoidCallback onNoneOfThese;
  final VoidCallback onDismiss;

  const MediaLinkDialog({
    super.key,
    required this.proposal,
    required this.onLink,
    required this.onNoneOfThese,
    required this.onDismiss,
  });

  @override
  State<MediaLinkDialog> createState() => _MediaLinkDialogState();
}

class _MediaLinkDialogState extends State<MediaLinkDialog> {
  late MediaLinkCandidate? _selected = widget.proposal.candidates.isEmpty
      ? null
      : widget.proposal.candidates.first;

  String _serviceLabel(Service service) => '${service.name[0].toUpperCase()}${service.name.substring(1)}';

  String _disambiguators(BuildContext context, MediaLinkCandidate candidate) {
    return <String>[
      if (candidate.year != null) '${candidate.year}',
      if (candidate.format != null && candidate.format!.isNotEmpty) candidate.format!.toUpperCase(),
      context.tr(
        'dialog_entry_id',
        namedArgs: <String, String>{
          'service': _serviceLabel(candidate.service),
          'id': candidate.nativeId,
        },
      ),
    ].join('  •  ');
  }

  @override
  Widget build(BuildContext context) {
    final MediaLinkProposal proposal = widget.proposal;
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      child: SizedBox(
        width: 780.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 28.0.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('dialog_which_entry_title'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14.h),
              Text(
                context.tr(
                  'dialog_link_mismatch_body',
                  namedArgs: <String, String>{
                    'userService': _serviceLabel(proposal.userService),
                    'metadataService': _serviceLabel(proposal.metadataService),
                  },
                ),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              SizedBox(height: 20.h),
              ...proposal.candidates.map(
                (candidate) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: UnyoInkWell(
                    onTap: () => setState(() => _selected = candidate),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: _selected == candidate ? 0.16 : 0.05),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: _selected == candidate ? Colors.white : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _disambiguators(context, candidate),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    text: context.tr('dialog_none_of_these'),
                    maxHeight: 44,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onNoneOfThese();
                    },
                  ),
                  SizedBox(width: 12.w),
                  DarkUnyoButton(
                    text: context.tr('common_dismiss'),
                    maxHeight: 44,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDismiss();
                    },
                  ),
                  SizedBox(width: 12.w),
                  LightUnyoButton(
                    text: context.tr('dialog_link'),
                    maxHeight: 44,
                    onPressed: () {
                      final MediaLinkCandidate? selected = _selected;
                      if (selected == null) return;
                      Navigator.of(context).pop();
                      widget.onLink(selected);
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
