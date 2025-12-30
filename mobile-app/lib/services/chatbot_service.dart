import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class ChatbotService {
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile'; // Updated to supported model

  // Chat history to maintain context
  final List<Map<String, String>> _chatHistory = [];

  /// Send a message to the AI chatbot and get a response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      print('Sending message to Groq API...');
      print('API Key: ${ApiKeys.groqApiKey.substring(0, 10)}...');

      // Prepare the request
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful agricultural assistant specializing in black pepper farming. '
                  'Provide practical advice on cultivation, disease management, quality improvement, and market insights. '
                  'Keep responses concise and actionable.',
            },
            ..._chatHistory,
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'];

        // Add assistant response to history
        _chatHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        return assistantMessage;
      } else {
        print('API Error: ${response.statusCode}');
        print('Response: ${response.body}');

        // Parse error message if available
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
          return 'API Error: $errorMsg (Status: ${response.statusCode})';
        } catch (_) {
          return 'API Error: ${response.statusCode}. Please check your API key and try again.';
        }
      }
    } catch (e, stackTrace) {
      print('Chatbot error: $e');
      print('Stack trace: $stackTrace');
      return 'Error: ${e.toString()}. Please check your internet connection and API key.';
    }
  }

  /// Clear chat history
  void clearHistory() {
    _chatHistory.clear();
  }

  /// Get chat history
  List<Map<String, String>> getHistory() {
    return List.from(_chatHistory);
  }
}

