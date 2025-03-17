import 'dart:typed_data';
import 'package:hive/hive.dart';

//part 'face_data.dart';

@HiveType(typeId: 0)
class FaceData extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final Uint8List faceFeatures;

  @HiveField(2)
  final DateTime dateAdded;

  FaceData({
    required this.name,
    required this.faceFeatures,
    required this.dateAdded,
  });
}
