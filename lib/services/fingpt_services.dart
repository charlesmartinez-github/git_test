import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatGPTService {
  final String apiKey = 'YOUR_OPENAI_API_KEY';

  Future<String> getChatGPTResponse(String message) async {
    const String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    var request = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 150,
    });

    var response = await http.post(Uri.parse(apiUrl), headers: headers, body: request);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get a response from ChatGPT');
    }
  }
}
