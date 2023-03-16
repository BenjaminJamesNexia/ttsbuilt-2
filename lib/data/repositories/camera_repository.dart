import 'package:camera/camera.dart';

class CameraRepository{
  List<CameraDescription> cameras = [];
  CameraController? _controller;
  bool _isCameraControllerInitialized = false;
  CameraRepository(){
    initialiseCameras();
  }
  void initialiseCameras() async{
    cameras = await availableCameras();
  }

  Future<CameraController?> getController() async{
    if(_isCameraControllerInitialized == false && cameras.length > 0){
      CameraDescription cameraDescription = cameras.first;
      _controller = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      _isCameraControllerInitialized = true;
    }
    return _controller;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    _controller = cameraController;

    // Initialize controller
    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    _isCameraControllerInitialized = true;
  }

  void dispose(){
    if(_isCameraControllerInitialized){
      _controller!.dispose();
      _isCameraControllerInitialized = false;
    }
  }

}