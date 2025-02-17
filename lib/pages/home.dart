import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null || cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: CameraPreview(
                cameraController!,
              ),
            ),
            IconButton(
              onPressed: () async {
                XFile picture = await cameraController!.takePicture();

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => DisplayPictureScreen(
                      imagePath: picture.path,
                    ),
                  ),
                );
              },
              iconSize: 100,
              icon: const Icon(
                Icons.camera,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _setupCameraController() async {
    List<CameraDescription> checkCameras = await availableCameras();
    if (checkCameras.isNotEmpty) {
      setState(() {
        cameras = checkCameras;
        cameraController = CameraController(
            checkCameras.last,
            ResolutionPreset.high
        );
      });
      cameraController?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError(
        (Object e) {
        },
      );
    }
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}