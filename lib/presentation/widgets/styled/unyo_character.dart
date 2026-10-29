import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

class UnyoCharacter extends StatelessWidget {
  final String tag;
  final String name;
  final String image;
  final void Function()? onPressed;

  const UnyoCharacter({super.key, required this.tag, required this.onPressed, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: SizedBox(
        width: 152.5,
        height: 256,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UnyoInkWell(
              onTap: onPressed,
              // TODO maybe Stack over HoverAnimatedContainer
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  HoverAnimatedContainer(
                    width: 140.0 /*.w.clamp(144.08, 181.7)*/,
                    hoverWidth: 152.5 /*.w.clamp(156.49, 199.1)*/,
                    height: 200.5 /*.h.clamp(200.44, 260.6)*/,
                    hoverHeight: 213.0 /*.h.clamp(206.03, 268.44)*/,
                    hoverCursor: SystemMouseCursors.click,
                    hoverDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2.6),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: UnyoNetworkImage(
                            url: image,
                            fit: BoxFit.fill,
                            borderRadius: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140.0 /*.w.clamp(144.08, 181.7)*/,
              height: 24,
              child: Center(
                child: Tooltip(
                  message: name,
                  waitDuration: const Duration(milliseconds: 1000),
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
