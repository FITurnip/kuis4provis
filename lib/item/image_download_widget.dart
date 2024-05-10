import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageDownloadWidget extends StatefulWidget {
  String imgUrl;
  ImageDownloadWidget(imgUrl) : this.imgUrl = imgUrl;

  @override
  _ImageDownloadWidgetState createState() => _ImageDownloadWidgetState();
}

class _ImageDownloadWidgetState extends State<ImageDownloadWidget> {
  Uint8List? imageData;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imgUrl;
    fetchImage();
  }

  Future<void> fetchImage() async {
    String accessToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImZyYW5rdGVzdCIsImV4cCI6MTcxNTQ0NDkxN30.OZ2iiNspE0WBz2tnFdr0RbMoojBU1OoTy0abwj8nDbQ"; // Replace with your actual access token

    try {
      http.Response response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Authorization':
              'Bearer $accessToken', // Include OAuth token in headers
          'Client-ID': '8',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes;
        });
      } else {
        print("Failed to download image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return CircularProgressIndicator(); // Show loading indicator while fetching image
    } else {
      return Image.memory(imageData!, width: 60, height: 60, fit: BoxFit.cover,); // Display the downloaded image
    }
  }
}
