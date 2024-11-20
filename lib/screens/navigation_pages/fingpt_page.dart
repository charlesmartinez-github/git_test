import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/account_provider.dart'; // Add SharedPreferences dependency



class FinGPTPage extends StatelessWidget {
  const FinGPTPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fin-GPT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _db = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final Dio _dio = Dio();
  final stt.SpeechToText _speech = stt.SpeechToText();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> conversationHistory =
  []; // Stores conversations with titles
  int? currentConversationIndex;
  List<String> floatingSuggestions = [
    "Create a budget for me based on my income and expenses.",
    "Analyze my spending habits and identify areas where I can cut back.",
    "Set up a savings goal and create a plan to reach it."
  ];

  File? _selectedImage;
  bool _isProcessing = false;
  bool _isListening = false;
  bool showSuggestions = true; // Controls visibility of suggestions

  static const String apiUrl = "https://api.openai.com/v1/chat/completions";
  static const String apiKey =
      "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"; // Replace with your actual OpenAI API key

  // Add methods to save and load chat history
  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Listen to text input changes
    _controller.addListener(() {
      setState(() {
        showSuggestions = _controller.text.isEmpty;
      });
    });
  }

  Future<void> _saveConversation(String title) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    final jsonMessages = jsonEncode(messages);

    // Save to Firestore
    final conversationRef = _db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .doc(selectedAccount)
        .collection('conversations')
        .doc(); // Automatically generate new ID

    await conversationRef.set({
      'title': title,
      'messages': jsonMessages,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also update local conversationHistory for UI purposes
    setState(() {
      conversationHistory.add({
        'title': title,
        'messages': jsonMessages,
      });
      currentConversationIndex = conversationHistory.length - 1; // Set as current
    });
  }


  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConversations = prefs.getStringList('conversations') ?? [];

    setState(() {
      conversationHistory = savedConversations
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({"role": "user", "content": message, "isImage": false});
      _controller.clear(); // Clear the TextField
    });
    showSuggestions = false;
    final response = await _sendTextRequestToGPT(message);

    setState(() {
      messages.add({
        "role": "assistant",
        "content": response,
        "isImage": false,
      });
    });

    // If this is an existing conversation, update it
    if (currentConversationIndex != null) {
      conversationHistory[currentConversationIndex!]['messages'] =
          jsonEncode(messages);
    } else {
      // Create a new conversation if it's the first message
      final title = await _generateSummaryTitle(response);
      await _saveConversation(title);
      currentConversationIndex =
          conversationHistory.length - 1; // Set as current
    }
  }

  // Function to generate a summary for the conversation title
  Future<String> _generateSummaryTitle(String response) async {
    try {
      final summaryResponse = await _dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": "Summarize the following text into a brief title."
            },
            {"role": "user", "content": response},
          ],
        }),
      );

      if (summaryResponse.statusCode == 200) {
        return summaryResponse.data['choices'][0]['message']['content'];
      } else {
        return "Conversation on: ${response.split(' ').take(3).join(' ')}";
      }
    } catch (error) {
      // If summarization fails, use the first few words as the title
      return "Conversation on: ${response.split(' ').take(3).join(' ')}";
    }
  }

  Future<void> analyzeImage(File image) async {
    setState(() {
      messages.add({"role": "user", "content": image, "isImage": true});
      _isProcessing = true;
    });

    try {
      final analysisResult = await _sendImageToGPT4OMini(image);
      setState(() {
        messages.add({
          "role": "assistant",
          "content": analysisResult,
          "isImage": false,
        });
      });
    } catch (error) {
      _showErrorSnackBar("Image analysis failed: $error");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String> _sendTextRequestToGPT(String message) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    String? selectedAccount = context.read<AccountProvider>().selectedAccount;

    if (selectedAccount == null) {
      throw Exception('No account selected');
    }

    final accountDoc = await _db.collection('users').doc(userId).collection('accounts').doc(selectedAccount).get();
    String accountName = accountDoc['accountName'] ?? 'Unnamed Account';
    double funds = (accountDoc['funds'] ?? 0).toDouble();

    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": "You are a finance assistant app for $accountName. "
                  "This account has a budget of $funds. Respond accordingly to the user's questions."
            },
            {"role": "user", "content": message},
          ]
        }),
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error in text request: $error");
    }
  }


  Future<String> _sendImageToGPT4OMini(File image) async {
    final String base64Image = await _encodeImage(image);

    try {
      final response = await _dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                  "What is in this image? explain the contents of the image and if there a list of prices you will total amount(example a reciept)and show it to the user",
                },
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
                },
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error in image request: $error");
    }
  }

  Future<String> _encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      await analyzeImage(_selectedImage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Center(
          child: Text(
            "Fin-GPT",
            style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // "+" button
            onPressed: () {
              setState(() {
                messages = []; // Clear current messages
                currentConversationIndex = null; // No conversation selected
                showSuggestions =
                true; // Show suggestions for new conversations
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification actions here
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Column(
                children: [
                  Text(
                    textAlign: TextAlign.end,
                    "Chat History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: conversationHistory.map((conversation) {
                  return ListTile(
                    title: Text(conversation['title']),
                    onTap: () {
                      setState(() {
                        currentConversationIndex = conversationHistory.indexOf(conversation);
                        messages = List<Map<String, dynamic>>.from(
                          jsonDecode(conversation['messages']),
                        );
                        showSuggestions = false; // Hide suggestions when loading a conversation
                      });
                      Navigator.pop(context); // Close the drawer
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // Logo Section
              if (messages.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'images/logo.png', // Path to your logo.png
                      height: 150,
                    ),
                  ),
                ),

              // Expanded Messages List
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index];
                    bool isUserMessage = msg['role'] == 'user';

                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.blue[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: msg['isImage']
                            ? Column(
                          crossAxisAlignment: isUserMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Image.file(
                              msg['content'],
                              height: 150,
                              width: 150,
                            ),
                            const Text(
                              "User Image",
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.black54),
                            ),
                          ],
                        )
                            : Text(
                          msg['content'],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                          textAlign: isUserMessage
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),

              // Input Field
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Enter your message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                30.0), // Rounded corners for text box
                            borderSide: BorderSide.none, // No visible border
                          ),
                          filled: true,
                          fillColor: Colors
                              .grey[200], // Light background color for text box
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                left: 1.0), // Adjust padding
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Ensure the row takes minimal space
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.image),
                                  onPressed: pickImage,
                                  tooltip: "Pick an image", // Optional tooltip
                                ),
                                IconButton(
                                  icon: Icon(_isListening
                                      ? Icons.mic
                                      : Icons.mic_none),
                                  onPressed: _listen,
                                  tooltip:
                                  "Start listening", // Optional tooltip
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 1), // Space between text box and send button
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          sendMessage(_controller.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Suggestions Positioned Above the Input Field
          if (showSuggestions)
            Positioned(
              bottom:
              70, // Adjust this value to keep suggestions above the input box
              right: 10, // Align suggestions to the bottom-right
              left: 10, // Keep some padding on the left
              child: SingleChildScrollView(
                scrollDirection:
                Axis.horizontal, // Make it horizontally scrollable
                child: Row(
                  children: floatingSuggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0), // Add spacing between buttons
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _controller.text = suggestion;
                            showSuggestions =
                            false; // Hide suggestions after selection
                          });
                          sendMessage(suggestion);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          backgroundColor: Colors.lightBlue[100],
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
