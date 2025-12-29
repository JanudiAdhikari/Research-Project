import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GeminiService {
  // Groq API Configuration (FREE tier - no credit card required!)
  // Get your API key from: https://console.groq.com/keys
  // Configure in: lib/config/api_keys.dart
  static final String _apiKey = ApiKeys.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  final List<Map<String, String>> _chatHistory = [];

  GeminiService() {
    // Initialize with system prompt for black pepper farming expertise
    _chatHistory.add({
      'role': 'system',
      'content': '''You are an expert agricultural assistant specializing in black pepper (Piper nigrum) cultivation. 
You provide helpful, accurate advice to farmers about:
- Black pepper plant care and maintenance
- Disease identification and prevention (yellow mottle virus, fungal infections, etc.)
- Pest management
- Soil requirements and fertilization
- Irrigation and water management
- Harvesting techniques and timing
- Post-harvest processing (drying, grading)
- Weather-related farming tips
- Market trends and pricing

Always provide practical, actionable advice tailored to tropical climates like Sri Lanka. 
Keep responses clear, concise, and farmer-friendly. Use simple language that farmers can understand.'''
    });

    // Add assistant's initial greeting
    _chatHistory.add({
      'role': 'assistant',
      'content': '''I understand. I'm here to help farmers with all aspects of black pepper cultivation. 
I'll provide practical, easy-to-understand advice for growing healthy pepper plants and maximizing yields. 
What would you like to know about black pepper farming?'''
    });
  }

  /// Send a message and get response from Groq AI
  Future<String> sendMessage(String message) async {
    try {
      print('🤖 Sending message to Groq AI: $message');
      print('📡 Using Groq API (LLaMA 3.3 70B - Free!)');

      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'content': message,
      });

      // Prepare request body - Using LLaMA 3.3 70B (free and powerful!)
      final requestBody = {
        'model': 'llama-3.3-70b-versatile',
        'messages': _chatHistory,
        'temperature': 0.7,
        'max_tokens': 1024,
        'stream': false,
      };

      print('🔑 API Key configured: ${_apiKey.substring(0, 10)}...');

      // Make API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final assistantMessage = data['choices'][0]['message']['content'] as String;

          // Add assistant response to history
          _chatHistory.add({
            'role': 'assistant',
            'content': assistantMessage,
          });

          print('✅ Received response from Groq AI');
          return assistantMessage;
        } else {
          print('⚠️ No response content in API response');
          return "I apologize, but I couldn't generate a response. Please try rephrasing your question.";
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';

        print('❌ API Error (${response.statusCode}): $errorMessage');

        // Handle specific error cases
        if (response.statusCode == 401) {
          return "⚠️ **API Key Error**\n\n"
              "Your Groq API key is invalid or expired.\n\n"
              "Please:\n"
              "1. Visit: https://console.groq.com/keys\n"
              "2. Generate a new API key (FREE!)\n"
              "3. Update it in the app settings\n"
              "4. Restart the app";
        } else if (response.statusCode == 429) {
          return "⚠️ **Rate Limit Exceeded**\n\n"
              "You've made too many requests. Please wait a moment and try again.\n\n"
              "Groq free tier: 30 requests/minute, 14,400 requests/day\n"
              "This is very generous - just wait a bit!";
        } else {
          return "⚠️ **Error Occurred**\n\n"
              "Error: $errorMessage\n\n"
              "Please try again or contact support if the issue persists.";
        }
      }
    } catch (e) {
      print('❌ Error sending message to Groq: $e');
      print('🔍 Full error details: ${e.toString()}');

      final errorString = e.toString().toLowerCase();

      if (errorString.contains('timeout')) {
        return "⚠️ **Connection Timeout**\n\n"
            "The request took too long. Please check your internet connection and try again.";
      } else if (errorString.contains('socket') || errorString.contains('network')) {
        return "⚠️ **Network Error**\n\n"
            "Please check your internet connection and try again.";
      } else {
        return "⚠️ **Unexpected Error**\n\n"
            "Sorry, I encountered an error: ${e.toString().split('\n').first}\n\n"
            "Please try again.";
      }
    }
  }

  /// Get chat history
  List<Map<String, String>> getChatHistory() {
    return List.from(_chatHistory);
  }

  /// Clear chat and start fresh
  void resetChat() {
    _chatHistory.clear();

    // Re-initialize with system prompt
    _chatHistory.add({
      'role': 'system',
      'content': '''You are an expert agricultural assistant specializing in black pepper (Piper nigrum) cultivation. 
You provide helpful, accurate advice to farmers about:
- Black pepper plant care and maintenance
- Disease identification and prevention
- Pest management
- Soil requirements and fertilization
- Irrigation and water management
- Harvesting techniques and timing
- Post-harvest processing (drying, grading)
- Weather-related farming tips
- Market trends and pricing

Always provide practical, actionable advice tailored to tropical climates like Sri Lanka. 
Keep responses clear, concise, and farmer-friendly.'''
    });

    _chatHistory.add({
      'role': 'assistant',
      'content': 'Chat reset! How can I help you with black pepper farming today?'
    });
  }
}

