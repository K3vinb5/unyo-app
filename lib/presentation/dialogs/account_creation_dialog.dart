// External dependencies
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/enums/login_card_type.dart';
import 'package:unyo/presentation/widgets/styled/styled.dart';
import 'package:unyo/presentation/widgets/text/text_display_large.dart';

/// The "Add a new account" dialog: pick the service the new account belongs to,
/// then Confirm (the cubit starts the provider flow) or Cancel.
///
/// Presentational on purpose (WP #111): every interaction is a callback, so the
/// dialog can be pumped on its own at any window size instead of having to
/// stand up a `LoginCubit`. `LoginCubit.initiateAccountCreation` owns the wiring.
///
/// Four 200.w cards never fit inside a 0.6.sw dialog (four cards are ~896.w
/// against a ~600px body at a 1000px window), so the selector is a clipped,
/// horizontally scrolling carousel with an always-visible scrollbar. Wheel (any
/// axis), mouse drag and arrow/Page/Home/End keys all move it; the dialog height
/// is derived from its content, so the action row can never be pushed out of the
/// surface.
class AccountCreationDialog extends StatelessWidget {
  const AccountCreationDialog({
    super.key,
    required this.selectedType,
    required this.onSelect,
    required this.onCancel,
    required this.onConfirm,
  });

  final LoginCardType selectedType;
  final ValueChanged<LoginCardType> onSelect;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  /// The scrolling service selector (the carousel viewport).
  static const Key selectorKey = ValueKey<String>('account-creation-selector');

  static const Key cancelKey = ValueKey<String>('account-creation-cancel');

  static const Key confirmKey = ValueKey<String>('account-creation-confirm');

  /// Key of the card that selects [type], so a driven run can tap/assert one
  /// service without depending on a label's glyph coverage.
  static Key cardKey(LoginCardType type) =>
      ValueKey<String>('account-creation-card-${type.name}');

  /// Design-pixel height of a [LoginCard].
  static const double cardExtent = 200;

  /// Room kept under the cards for the scrollbar, so the thumb never paints
  /// over a card's bottom border.
  static const double scrollbarGutter = 14;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      // Height is content-driven: the old fixed 0.6.sh box is what clipped the
      // action row once the cards spilled out of the body.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 0.6.sw,
          maxWidth: 0.6.sw,
          maxHeight: 0.9.sh,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 28.h),
            TextDisplayLarge(text: context.tr("dialog_sign_in_title")),
            SizedBox(height: 20.h),
            Flexible(
              child: _AccountServiceSelector(
                selectedType: selectedType,
                onSelect: onSelect,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DarkUnyoButton(
                    key: cancelKey,
                    onPressed: onCancel,
                    text: context.tr("common_cancel"),
                  ),
                  SizedBox(width: 15.w),
                  LightUnyoButton(
                    key: confirmKey,
                    onPressed: onConfirm,
                    text: context.tr("common_confirm"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One account service offered by the dialog.
class _ServiceOption {
  const _ServiceOption({
    required this.type,
    this.title,
    required this.asset,
    required this.logoSize,
  });

  final LoginCardType type;

  /// Brand name, shown verbatim and never translated. Null for the services
  /// whose card title is app copy ([_cardTitle] resolves it through a key).
  final String? title;

  final String asset;
  final double logoSize;
}

/// The offered services, in display order. Brand marks are the ones the picker
/// already ships.
const List<_ServiceOption> _serviceOptions = <_ServiceOption>[
  _ServiceOption(
    type: LoginCardType.anilist,
    title: 'Anilist',
    asset: 'assets/images/anilist.svg',
    logoSize: 120,
  ),
  _ServiceOption(
    type: LoginCardType.shikimori,
    title: 'Shikimori',
    asset: 'assets/images/shikimori.svg',
    logoSize: 120,
  ),
  _ServiceOption(
    type: LoginCardType.mal,
    title: 'MyAnimeList',
    asset: 'assets/images/myanimelist.svg',
    logoSize: 120,
  ),
  _ServiceOption(
    type: LoginCardType.local,
    asset: 'assets/images/local_account.svg',
    logoSize: 130,
  ),
];

/// Card title: provider brand names stay as they are (the list is `const`, so
/// the brand name is the only per-service copy it can carry), the local account
/// is app copy and goes through the catalog.
String _cardTitle(BuildContext context, _ServiceOption option) =>
    option.title ?? context.tr('dialog_account_local_title');

/// Card description: "Sync your list with {provider}" for the three provider
/// services, app copy for the offline local account.
String _cardDescription(BuildContext context, _ServiceOption option) =>
    option.title == null
        ? context.tr('dialog_account_local_description')
        : context.tr(
            'dialog_account_sync_provider',
            namedArgs: <String, String>{'provider': option.title!},
          );

/// The horizontally scrolling row of [LoginCard]s.
///
/// A plain horizontal [ScrollView] ignores a vertical mouse wheel, and desktop
/// scroll views do not accept a mouse drag by default, so both are wired up
/// here instead of being left to platform defaults.
class _AccountServiceSelector extends StatefulWidget {
  const _AccountServiceSelector({
    required this.selectedType,
    required this.onSelect,
  });

  final LoginCardType selectedType;
  final ValueChanged<LoginCardType> onSelect;

  @override
  State<_AccountServiceSelector> createState() => _AccountServiceSelectorState();
}

class _AccountServiceSelectorState extends State<_AccountServiceSelector> {
  /// How far one arrow-key press moves, in design pixels.
  static const double _keyStep = AccountCreationDialog.cardExtent / 2;

  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ScrollPosition? get _position =>
      _controller.hasClients ? _controller.position : null;

  void _scrollBy(double delta, {bool animate = true}) {
    final ScrollPosition? position = _position;
    if (position == null || !position.hasContentDimensions) return;
    if (position.maxScrollExtent <= position.minScrollExtent) return;
    final double target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return;
    if (animate) {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    // Either axis drives the carousel: a wheel over a horizontal list sends dy.
    final double delta = event.scrollDelta.dy != 0
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) return;
    _scrollBy(delta, animate: false);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final ScrollPosition? position = _position;
    if (position == null) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _scrollBy(_keyStep);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _scrollBy(-_keyStep);
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollBy(position.viewportDimension);
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollBy(-position.viewportDimension);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _scrollBy(position.minScrollExtent - position.pixels);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _scrollBy(position.maxScrollExtent - position.pixels);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: AccountCreationDialog.selectorKey,
      height: (AccountCreationDialog.cardExtent +
              AccountCreationDialog.scrollbarGutter)
          .h,
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKey,
        child: ScrollConfiguration(
          // Mouse drag is not a scroll gesture on desktop by default.
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const <PointerDeviceKind>{
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
              PointerDeviceKind.unknown,
            },
          ),
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(3),
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  bottom: AccountCreationDialog.scrollbarGutter.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final _ServiceOption option in _serviceOptions)
                      LoginCard(
                        key: AccountCreationDialog.cardKey(option.type),
                        logo: SvgPicture.asset(
                          option.asset,
                          width: option.logoSize.w,
                          height: option.logoSize.h,
                        ),
                        title: _cardTitle(context, option),
                        description: _cardDescription(context, option),
                        onTap: () => widget.onSelect(option.type),
                        isSelected: widget.selectedType == option.type,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
