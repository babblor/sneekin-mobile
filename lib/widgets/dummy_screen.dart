import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _selectedImage;
  String? _uploadedImageUrl;
  final bool _isUploading = false;

  final Dio _dio = Dio();

  // Replace with your GCP bucket details
  final String bucketName = "sneek-images";
  final String serviceAccountPath = "path-to-your-service-account-key.json";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    try {
      // Generate upload URL
      final String fileName = basename(_selectedImage!.path);
      final String uploadUrl =
          "https://storage.googleapis.com/upload/storage/v1/b/$bucketName/o?uploadType=media&name=$fileName";

      // Read file bytes
      final fileBytes = await _selectedImage!.readAsBytes();

      // Make the Dio POST request
      final response = await _dio.post(
        uploadUrl,
        data: fileBytes,
      );

      log("response: ${response.data}");

      if (response.statusCode == 200) {
        setState(() {
          _uploadedImageUrl = "https://storage.googleapis.com/$bucketName/$fileName";
        });
        log("Image uploaded successfully!");
      } else {
        throw Exception("Failed to upload image: ${response.data}");
      }
    } catch (e) {
      log("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker & Uploader"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display selected image
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              const Placeholder(
                fallbackHeight: 200,
                fallbackWidth: double.infinity,
              ),
            const SizedBox(height: 20),

            // Upload Button
            if (_isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload Image"),
            ),

            const SizedBox(height: 20),

            // Display uploaded image URL
            if (_uploadedImageUrl != null)
              const Text(
                "Uploaded Image URL:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (_uploadedImageUrl != null)
              SelectableText(
                _uploadedImageUrl!,
                style: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
