import 'package:image_picker/image_picker.dart';

class ImagePickerManager {
  static ImagePickerManager? _instance;

  ImagePickerManager._();

  static ImagePickerManager get instance =>
      _instance ??= ImagePickerManager._();

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(
      {required ImageSource source,
      double? maxWidth,
      double? maxHeight,
      int? quality}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      return pickedFile;
    } catch (e) {
      return null;
    }
  }

  Future<List<XFile>> pickImages(
      {double? maxWidth, double? maxHeight, int? quality}) async {
    try {
      final List<XFile> pickedFile = await _picker.pickMultiImage();
      return pickedFile;
    } catch (e) {
      return [];
    }
  }
}
