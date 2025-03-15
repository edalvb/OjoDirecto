import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teleprompter App',
      theme: ThemeData.dark(),
      home: TeleprompterCameraPage(),
    );
  }
}

class TeleprompterCameraPage extends StatefulWidget {
  @override
  _TeleprompterCameraPageState createState() => _TeleprompterCameraPageState();
}

class _TeleprompterCameraPageState extends State<TeleprompterCameraPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _usingRearCamera = true;

  String _teleprompterText =
      "Aquí va tu guion. Habla con naturalidad y mantén la mirada en la cámara.";
  double _teleprompterAreaHeightFactor = 0.2;
  double _scrollSpeed = 20.0;

  final ScrollController _textScrollController = ScrollController();
  AnimationController? _scrollAnimationController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initScrollAnimation();
  }

  void _initializeCamera() {
    final filteredCameras =
        cameras.where((camera) {
          if (_usingRearCamera)
            return camera.lensDirection == CameraLensDirection.back;
          else
            return camera.lensDirection == CameraLensDirection.front;
        }).toList();

    final selectedCamera = filteredCameras.first;
    _controller = CameraController(selectedCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _initScrollAnimation() {
    _scrollAnimationController?.dispose();
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _scrollSpeed.toInt()),
    )..addListener(() {
      if (_textScrollController.hasClients) {
        final maxScroll = _textScrollController.position.maxScrollExtent;
        final currentValue = _scrollAnimationController!.value;
        _textScrollController.jumpTo(currentValue * maxScroll);
      }
    });

    _scrollAnimationController?.repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scrollAnimationController?.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  void _updateScrollSpeed(double newSpeed) {
    setState(() {
      _scrollSpeed = newSpeed;

      // NUEVO: Modificamos Solo la duración, NO reiniciamos el teleprompter desde el inicio
      final currentProgress = _scrollAnimationController!.value;
      _scrollAnimationController!.duration = Duration(
        seconds: _scrollSpeed.toInt(),
      );
      _scrollAnimationController!
        ..reset()
        ..forward(from: currentProgress);
      _scrollAnimationController?.repeat();
    });
  }

  void _editTeleprompterText() {
    final editingController = TextEditingController(text: _teleprompterText);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar guion'),
            content: TextField(
              controller: editingController,
              maxLines: 5,
              decoration: InputDecoration(hintText: 'Escribe tu guion aquí...'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _teleprompterText = editingController.text;
                    _initScrollAnimation();
                  });
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  void _toggleCamera() {
    setState(() {
      _usingRearCamera = !_usingRearCamera;
      _controller?.dispose();
      _initializeCamera();
    });
  }

  Future<void> _toggleRecording() async {
    if (_controller == null) return;

    if (_isRecording) {
      final XFile file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📁: ${file.path}'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: "Abrir",
            onPressed: () {
              // NUEVO: abrir carpeta con el archivo grabado (usando open_file)
              OpenFile.open(File(file.path).parent.path);
            },
          ),
        ),
      );
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('OjoDirecto'),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _editTeleprompterText),
          IconButton(icon: Icon(Icons.switch_camera), onPressed: _toggleCamera),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.blue,
        onPressed: _toggleRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller!.value.isInitialized) {
            return Stack(
              children: [
                CameraPreview(_controller!),

                // NUEVO: Teleprompter en la parte superior.
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _teleprompterAreaHeightFactor +=
                            details.delta.dy / screenHeight;
                        _teleprompterAreaHeightFactor =
                            _teleprompterAreaHeightFactor.clamp(0.1, 0.5);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * _teleprompterAreaHeightFactor,
                      color: Colors.black.withOpacity(0.45),
                      child: SingleChildScrollView(
                        controller: _textScrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _teleprompterText,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 50,
                  right: 20,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => _updateScrollSpeed(
                              (_scrollSpeed - 2).clamp(5.0, 60.0),
                            ),
                        child: Text('+ Velocidad'),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => _updateScrollSpeed(
                              (_scrollSpeed + 2).clamp(5.0, 60.0),
                            ),
                        child: Text('- Velocidad'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
