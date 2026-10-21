import 'package:material_ui/material_ui.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingView extends StatelessWidget {
  final double width;
  final String description;

  const LoadingView({super.key, this.width = 120, this.description = ""});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.inkDrop(color: Colors.white, size: 35),
            SizedBox(height: description.isNotEmpty ? 20 : 0),
            Text(description, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        // Center(
        //   child: Container(
        //     width: width,
        //     decoration: BoxDecoration(
        //       image: DecorationImage(
        //         image: const AssetImage(
        //           'assets/logo.png',
        //         ),
        //         colorFilter:
        //             ColorFilter.mode(ColorScheme.of(context).primary, BlendMode.modulate),
        //       ),
        //     ),
        //   )
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 200),
        //   child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 30),
        // ),
      ],
    );
  }
}
