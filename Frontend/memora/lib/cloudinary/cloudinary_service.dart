import 'dart:io';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'cloudinary_apis.dart';

class CloudinaryService {
  late Cloudinary cloudinary;

  final String apiKey = CloudinaryData.apiKey;
  final String apiSecret = CloudinaryData.apiSecret;
  final String cloudName = CloudinaryData.cloudName;

  CloudinaryService()
  {
    cloudinary = Cloudinary.full(
      apiKey: CloudinaryData.apiKey,
      apiSecret: CloudinaryData.apiSecret,
      cloudName: CloudinaryData.cloudName,
    );
  }

  Future<String?> uploadImageUnsigned(File image, String presetName) async
  {
    try {
      final response = await cloudinary.unsignedUploadResource(
        CloudinaryUploadResource(
          uploadPreset: presetName,
          filePath: image.path,
          fileBytes: image.readAsBytesSync(),
          resourceType: CloudinaryResourceType.image,
          folder: CloudinaryData.folderProfiles,
          fileName: "${CloudinaryData.folderProfiles}_${DateTime.now().millisecondsSinceEpoch}",
          progressCallback: (count, total) {
            print('Uploading in progress: $count/$total');
          },
        ),
      );

      if (response.isSuccessful) {
        print('Uploaded pic URL-je: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Error when uploading: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> deleteImage(String publicId) async {
    try {
      final response = await cloudinary.deleteResource(
        publicId: publicId,
        resourceType: CloudinaryResourceType.image,
      );

      if (response.isSuccessful) {
        print("Image successfully deleted from Cloudinary.");
      } else {
        print("Error deleting image from Cloudinary: ${response.error}");
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<String?> getProfileImageUrl(String userName) async {
    try {
      // Constructing the URL directly based on userName and folder
      final imageUrl = 'https://res.cloudinary.com/${CloudinaryData.cloudName}/image/upload/v1/${CloudinaryData.folderProfiles}/$userName.png';
      return imageUrl;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  Future<String?> uploadImageForEvent(File image, String presetName, String eventDocId) async {
    try {
      // Mappa létrehozása az esemény ID alapján
      final folderPath = "event_folder/$eventDocId";

      final response = await cloudinary.unsignedUploadResource(
        CloudinaryUploadResource(
          uploadPreset: presetName,
          filePath: image.path,
          fileBytes: image.readAsBytesSync(),
          resourceType: CloudinaryResourceType.image,
          folder: folderPath,
          fileName: "${eventDocId}_${DateTime.now().millisecondsSinceEpoch}",
          progressCallback: (count, total) {
            print('Uploading in progress: $count/$total');
          },
        ),
      );

      if (response.isSuccessful) {
        print('Uploaded pic URL: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Error when uploading: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

}