import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  WidgetsFlutterBinding.ensureInitialized();
  return availableCameras();
});

Future<void> main() async {
  runApp(const ProviderScope(child: App()));
}
