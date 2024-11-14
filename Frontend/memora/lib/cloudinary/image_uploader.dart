import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageUploader {
  final String cloudName = 'SAJAT_CLOUD_NAME';
  final String uploadPreset = 'preset_name'; // A feltöltéshez használt upload preset neve

  Future<String?> uploadImage(File imageFile, String eventDocId) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = eventDocId; // Mappa az esemény ID alapján
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return responseData['secure_url']; // Visszaadjuk a kép URL-jét
      } else {
        print(
            'Hiba a kép feltöltésekor: ${responseData['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Kivétel a kép feltöltésekor: $e');
      return null;
    }
  }
}
