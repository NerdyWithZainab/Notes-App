import 'dart:convert';
import 'package:http/http.dart' as http;

class CalendarService {
  static const baseUrl =
      'http://localhost:8000'; // Replace with actual IP in real device

  static Future<Map<String, dynamic>> createEvent(String inputText) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_event/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_input': inputText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create event');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events/'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load events');
    }
  }
}
