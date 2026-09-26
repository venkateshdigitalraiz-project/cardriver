import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickImageUseCase {
  final ImagePicker _picker = ImagePicker();

  Future<String?> execute(ImageSource source) async {
    // Request storage/camera permissions first based on source
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (status.isDenied) return null;
    }
    
    // Attempt to pick an image
    final XFile? image = await _picker.pickImage(source: source);
    return image?.path;
  }
}
