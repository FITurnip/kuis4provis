import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis4/auth/shared_preferences_helper.dart';

class ImageDownloadWidget extends StatefulWidget {
  String imgUrl;
  ImageDownloadWidget(this.imgUrl, {super.key});

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
    String accessToken = await SharedPreferencesHelper.getPreference('access_token');
    String userId = '${await SharedPreferencesHelper.getPreference('user_id')}';

    try {
      http.Response response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Authorization':
              'Bearer $accessToken',
          'Client-ID': userId,
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
      return CircularProgressIndicator();
    } else {
      return Image.memory(imageData!, width: 60, height: 60, fit: BoxFit.cover,);
    }
  }
}
