import 'package:http/http.dart' as http;
import 'dart:convert';

class GroqService {
  final String apiKey = "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";
  final String endpoint = "https://api.groq.com/analyze-driving";

  Future<Map<String, dynamic>> analyzeDriving(Map<String, dynamic> drivingData) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(drivingData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to analyze driving data.");
    }
  }
}