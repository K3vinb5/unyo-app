import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] in an app-shaped tree: a 1920x1080 desktop surface (so
/// screen-util units resolve 1:1 and geometry assertions stay readable), the
/// same design size the app uses, and a scroll view so columns can report
/// their natural height.
///
/// Pass [disableAnimations] to exercise the accessibility path.
Future<void> pumpSkeletonHarness(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  if (disableAnimations) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1200,
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: 1,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
