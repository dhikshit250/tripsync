// lib/services/image_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  // IMPORTANT: Replace 'YOUR_ACCESS_KEY' with your actual Unsplash API key
  static const String _accessKey = 'YOUR_ACCESS_KEY';
  static const String _baseUrl = 'https://api.unsplash.com/search/photos';

  Future<String> fetchImageForPlace(String placeName) async {
    const defaultImageUrl = 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1';

    if (_accessKey == 'YOUR_ACCESS_KEY') {
      // Return default image if the API key is not set
      return defaultImageUrl;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?query=$placeName&per_page=1&client_id=$_accessKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['urls']['regular'];
        }
      }
      return defaultImageUrl;
    } catch (e) {
      return defaultImageUrl;
    }
  }
}
