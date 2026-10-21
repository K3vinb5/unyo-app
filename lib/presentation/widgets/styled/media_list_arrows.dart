import 'package:material_ui/material_ui.dart';

class MediaListArrows extends StatelessWidget {
  const MediaListArrows(
      {super.key, required this.controller, required this.visible});

  final ScrollController controller;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return visible
        ? Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              controller.animateTo(controller.offset - 400,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            icon: const Icon(Icons.arrow_left),
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () {
              controller.animateTo(controller.offset + 400,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            icon: const Icon(Icons.arrow_right),
            color: Colors.white,
          ),
        ],
      ),
    )
        : const SizedBox();
  }
}
