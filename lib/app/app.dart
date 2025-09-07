import 'package:flutter/material.dart';
import '../features/teleprompter/teleprompter_view.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OjoDirecto',
      theme: ThemeData.dark(),
      home: const TeleprompterView(),
    );
  }
}
