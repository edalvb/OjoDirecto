import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

// Usamos TickerProviderStateMixin en vez de SingleTickerProviderStateMixin
class _TeleprompterCameraPageState extends State<TeleprompterCameraPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _usingRearCamera = true;

  // Variables del teleprompter
  String _teleprompterText =
      "Aquí va tu guion. Habla con naturalidad y mantén la mirada en la cámara.";
  double _teleprompterAreaHeightFactor =
      0.2; // porcentaje del alto (o ancho) en pantalla
  double _scrollSpeed =
      20.0; // en segundos, indica la duración del scroll a lo largo del texto

  // Controlador de desplazamiento de texto
  final ScrollController _textScrollController = ScrollController();

  // Controlador de animación para desplazar el texto
  AnimationController? _scrollAnimationController;

  // Variables para grabación de video
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initScrollAnimation();
  }

  void _initializeCamera() {
    // Filtramos cámaras según uso de la trasera o frontal
    final filteredCameras =
        cameras.where((camera) {
          if (_usingRearCamera) {
            return camera.lensDirection == CameraLensDirection.back;
          } else {
            return camera.lensDirection == CameraLensDirection.front;
          }
        }).toList();

    // Si hay varias, elegimos la primera (podrías elegir la de mayor resolución)
    final selectedCamera =
        filteredCameras.isNotEmpty ? filteredCameras.first : cameras.first;

    // Inicializamos el controlador de cámara
    _controller = CameraController(selectedCamera, ResolutionPreset.max);
    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _initScrollAnimation() {
    // Si ya existía, lo descartamos para no tener múltiples tickers
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

    // Arrancamos la animación en bucle
    _scrollAnimationController?.repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scrollAnimationController?.dispose();
    _textScrollController.dispose();
    super.dispose();
  }

  // Ajusta la velocidad de la animación de scroll y la reinicia
  void _updateScrollSpeed(double newSpeed) {
    setState(() {
      _scrollSpeed = newSpeed;
      _initScrollAnimation();
    });
  }

  // Editar el texto del teleprompter
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

  // Cambiar de cámara (delantera <-> trasera)
  void _toggleCamera() {
    setState(() {
      _usingRearCamera = !_usingRearCamera;
      _controller?.dispose();
      _initializeCamera();
    });
  }

  // Iniciar/Detener grabación
  Future<void> _toggleRecording() async {
    if (_controller == null) return;

    if (_isRecording) {
      // Detener grabación
      final XFile file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      // Puedes mostrar un SnackBar o hacer algo más con el archivo grabado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grabación detenida. Video guardado en: ${file.path}'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Iniciar grabación
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Ajusta el contenedor del teleprompter según orientación
    final teleprompterAreaHeight =
        orientation == Orientation.portrait
            ? screenHeight * _teleprompterAreaHeightFactor
            : screenWidth * _teleprompterAreaHeightFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text('OjoDirecto'),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _editTeleprompterText),
          IconButton(icon: Icon(Icons.switch_camera), onPressed: _toggleCamera),
        ],
      ),
      // Botón para grabar o detener grabación
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isRecording ? Colors.red : Colors.blue,
        onPressed: _toggleRecording,
        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          // Cuando la cámara esté lista
          if (snapshot.connectionState == ConnectionState.done &&
              _controller?.value.isInitialized == true) {
            return Stack(
              children: [
                // Vista previa de la cámara
                CameraPreview(_controller!),

                // Área inferior (o lateral) para el teleprompter
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _teleprompterAreaHeightFactor -=
                            details.delta.dy / screenHeight;

                        // Limitar entre 0.1 y 0.5, por ejemplo
                        if (_teleprompterAreaHeightFactor < 0.1) {
                          _teleprompterAreaHeightFactor = 0.1;
                        }
                        if (_teleprompterAreaHeightFactor > 0.5) {
                          _teleprompterAreaHeightFactor = 0.5;
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: teleprompterAreaHeight,
                      color: Colors.black.withOpacity(0.3),
                      child: SingleChildScrollView(
                        controller: _textScrollController,
                        scrollDirection: Axis.vertical,
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

                // Botones para ajustar la velocidad del teleprompter
                Positioned(
                  top: 50,
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
                      SizedBox(height: 10),
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
            // Mientras inicializa la cámara
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
