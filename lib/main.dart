import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'app/app.dart';

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  WidgetsFlutterBinding.ensureInitialized();
  return availableCameras();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    CameraPlatform.instance = CameraWindows();
  }

  runApp(const ProviderScope(child: App()));
}
