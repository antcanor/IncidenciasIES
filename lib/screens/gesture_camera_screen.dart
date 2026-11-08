import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class GestureCameraScreen extends StatefulWidget {
  const GestureCameraScreen({super.key});

  @override
  State<GestureCameraScreen> createState() => _GestureCameraScreenState();
}

class _GestureCameraScreenState extends State<GestureCameraScreen> {
  CameraController? _camera;
  PoseDetector? _poseDetector;
  List<Pose> _poses = [];
  XFile? _photo;
  bool _initializing = true;
  bool _processing = false;
  bool _gestureEnabled = false;
  String? _error;

  bool get _supportsPose =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_supportsPose) {
      if (mounted) setState(() => _initializing = false);
      return;
    }
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        throw StateError(
          'El permiso de cámara es necesario para detectar la pose.',
        );
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No hay ninguna cámara disponible.');
      }

      final camera = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
      );
      await camera.initialize();
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      await camera.startImageStream(_processCameraImage);
      if (!mounted) {
        await camera.dispose();
        return;
      }
      setState(() {
        _camera = camera;
        _gestureEnabled = true;
        _initializing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _initializing = false;
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_processing ||
        _photo != null ||
        _camera == null ||
        _poseDetector == null) {
      return;
    }
    _processing = true;
    try {
      final rotation = InputImageRotationValue.fromRawValue(
        _camera!.description.sensorOrientation,
      );
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (rotation == null || format == null || image.planes.length != 1) {
        return;
      }
      final input = InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
      final poses = await _poseDetector!.processImage(input);
      if (!mounted) return;
      setState(() => _poses = poses);
      if (poses.any(_isWristAboveShoulder)) {
        await _takePhoto();
      }
    } finally {
      _processing = false;
    }
  }

  bool _isWristAboveShoulder(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    return (leftWrist != null &&
            leftShoulder != null &&
            leftWrist.y < leftShoulder.y &&
            leftWrist.likelihood > 0.5) ||
        (rightWrist != null &&
            rightShoulder != null &&
            rightWrist.y < rightShoulder.y &&
            rightWrist.likelihood > 0.5);
  }

  Future<void> _takePhoto() async {
    final camera = _camera;
    if (camera == null || camera.value.isTakingPicture) return;
    await camera.stopImageStream();
    final photo = await camera.takePicture();
    if (!mounted) return;
    setState(() {
      _photo = photo;
      _gestureEnabled = false;
    });
  }

  Future<void> _manualPhoto() async {
    if (_camera == null) {
      if (mounted) {
        setState(() {
          _photo = null;
          _gestureEnabled = false;
        });
      }
      return;
    }
    await _takePhoto();
  }

  @override
  void dispose() {
    unawaited(_disposeCamera());
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    final camera = _camera;
    if (camera != null && camera.value.isStreamingImages) {
      await camera.stopImageStream();
    }
    await camera?.dispose();
    await _poseDetector?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara por gesto')),
      body: Stack(
        children: [
          Positioned.fill(child: _buildPreview()),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PosePainter(_poses)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildStatus(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FilledButton.icon(
                    key: const Key('btn_foto_respaldo'),
                    onPressed: _manualPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Hacer foto manualmente'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_photo != null) {
      return FutureBuilder(
        future: _photo!.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ColoredBox(
              color: Colors.black87,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      );
    }
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      return CameraPreview(camera);
    }
    return ColoredBox(
      color: Colors.blueGrey.shade900,
      child: Center(
        child: Icon(
          _supportsPose ? Icons.camera : Icons.camera_outdoor,
          size: 96,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final message = _initializing
        ? 'Solicitando permiso y preparando la cámara...'
        : _error ??
              (!_supportsPose
                  ? 'ML Kit requiere Android o iOS. Usa el botón táctil de respaldo.'
                  : _gestureEnabled
                  ? 'Levanta una muñeca por encima del hombro para hacer la foto.'
                  : 'Foto realizada.');
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.black.withValues(alpha: 0.72),
      child: ListTile(
        leading: Icon(
          _gestureEnabled ? Icons.accessibility_new : Icons.info_outline,
          color: Colors.cyanAccent,
        ),
        title: const Text(
          'Pose corporal',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          message,
          key: const Key('gesture_camera_status'),
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  final List<Pose> poses;

  const _PosePainter(this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    for (final pose in poses) {
      final points = <PoseLandmarkType, Offset>{};
      for (final entry in pose.landmarks.entries) {
        if (entry.value.likelihood > 0.5) {
          points[entry.key] = Offset(
            size.width - entry.value.x * size.width / 640,
            entry.value.y * size.height / 480,
          );
        }
      }
      const connections = [
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
        [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
        [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
        [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
        [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
        [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
      ];
      for (final connection in connections) {
        final start = points[connection[0]];
        final end = points[connection[1]];
        if (start != null && end != null) {
          canvas.drawLine(start, end, paint);
        }
      }
      for (final point in points.values) {
        canvas.drawCircle(point, 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) =>
      oldDelegate.poses != poses;
}
