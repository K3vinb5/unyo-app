import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/services/media_id_resolver.dart';
import 'package:unyo/domain/services/media_link_proposal.dart';
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

  String _disambiguators(MediaLinkCandidate candidate) {
    return <String>[
      if (candidate.year != null) '${candidate.year}',
      if (candidate.format != null && candidate.format!.isNotEmpty) candidate.format!.toUpperCase(),
      candidate.isAnime ? 'Anime' : 'Manga',
      '${_serviceLabel(candidate.service)} id ${candidate.nativeId}',
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
              const Text(
                "Which entry is this?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14.h),
              Text(
                "You're signed in with ${_serviceLabel(proposal.userService)}, but details come from "
                "${_serviceLabel(proposal.metadataService)}. We couldn't match this entry between the two "
                "automatically — pick the right one.",
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
                            _disambiguators(candidate),
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
                    text: "None of these",
                    maxHeight: 44,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onNoneOfThese();
                    },
                  ),
                  SizedBox(width: 12.w),
                  DarkUnyoButton(
                    text: "Dismiss",
                    maxHeight: 44,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDismiss();
                    },
                  ),
                  SizedBox(width: 12.w),
                  LightUnyoButton(
                    text: "Link",
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
