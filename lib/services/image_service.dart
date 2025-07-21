// lib/services/image_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  // Replace 'YOUR_ACCESS_KEY' with the key you got from Unsplash
  static const String _accessKey = 'YOUR_ACCESS_KEY';
  static const String _baseUrl = 'https://api.unsplash.com/search/photos';

  Future<String> fetchImageForPlace(String placeName) async {
    // A default image in case the search fails
    const defaultImageUrl = 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1';

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?query=$placeName&per_page=1&client_id=$_accessKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Get the URL of the first image found
          return data['results'][0]['urls']['regular'];
        }
      }
      // Return default image if no results or if there's an error
      return defaultImageUrl;
    } catch (e) {
      // Return default image on any exception
      return defaultImageUrl;
    }
  }
}