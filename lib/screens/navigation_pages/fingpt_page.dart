import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';       // For Clipboard
import 'package:share_plus/share_plus.dart';  // For sharing content


class FinGPT extends StatefulWidget {
  const FinGPT({super.key});

  @override
  State<FinGPT> createState() => _FinGPTState();
}

class _FinGPTState extends State<FinGPT> {
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
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final Dio _dio = Dio();




  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> conversationHistory = [];
  int? currentConversationIndex;
  List<String> floatingSuggestions = [
    "Create a budget for me based on my income and expenses.",
    "Analyze my spending habits and identify areas where I can cut back.",
    "Set up a savings goal and create a plan to reach it."
  ];

  File? _selectedImage;
  bool _isProcessing = false;
  bool showSuggestions = true;
  bool _showInputField = true;




  late AudioPlayer _audioPlayer;
  bool _isUploadingImage = false; // Add this line
  bool _isProcessingSpeech = false; // Separate from _isProcessing
  bool _isPlayingAudio = false;
  int _messageIdCounter = 0;
  int? _playingMessageId; // ID of the message being played




  late FlutterSoundRecorder _audioRecorder;
  String _audioFilePath = '';
  bool _isRecording = false;
  String _transcription = '';



  static const String apiUrl = "https://api.openai.com/v1/chat/completions";
  static const String apiKey =
      "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"; // Replace with your actual OpenAI API key

  // Variables for structured conversation
  Map<String, List<Map<String, String>>> conversationFlows = {
    "Create a budget for me based on my income and expenses.": [
      {"question": "What is your total monthly income?", "key": "income"},
      {"question": "What are your fixed monthly expenses?", "key": "fixedExpenses"},
      {
        "question": "Can you list your variable monthly expenses like groceries and entertainment?",
        "key": "variableExpenses"
      },
      {
        "question": "Do you currently pay any loans or debts?",
        "key": "debtQa"
      }
      ,
    ],
    "Analyze my spending habits and identify areas where I can cut back.": [
      {"question": "What is your total monthly income after taxes?",
        "key": "totalMonthlyIncomeAfterTaxes"
      },
      {"question": "Do you have any additional sources of income (bonuses, freelance work, etc.)?",
        "key": "additionalIncomeSources"
      },
      {
        "question": "How much do you allocate for transportation (fuel, public transit, car maintenance)?",
        "key": "transportationAllocation"
      },
      {
        "question": "Are there any subscriptions or memberships you regularly pay for?",
        "key": "subscriptionsOrMemberships"
      },
      {
        "question": "How much do you typically spend on groceries each month?",
        "key": "monthlyGroceries"
      },
      {
        "question": "What areas would you like to focus on cutting back?",
        "key": "cutbackAreas"
      },
    ],
    "Set up a savings goal and create a plan to reach it.": [
      {"question": "What is your savings goal amount?", "key": "savingsGoal"},
      {"question": "In how many months would you like to achieve this goal?", "key": "goalMonths"},
      {
        "question": "How much can you save monthly toward this goal?",
        "key": "monthlySavings"
      },
    ],
  };













  List<Map<String, String>>? currentConversationFlow;
  int currentQuestionIndex = 0;
  Map<String, String> userResponses = {};
  bool isStructuredConversation = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Listen to text input changes
    _controller.addListener(() {
      setState(() {
        showSuggestions = _controller.text.isEmpty && !isStructuredConversation;
      });
    });
    // Initialize the audio recorder
    _audioRecorder = FlutterSoundRecorder();
    _initAudioRecorder();
    _audioPlayer = AudioPlayer();
  }


  Future<void> _initAudioRecorder() async {
    await _audioRecorder.openRecorder();
  }






  Future<void> generateSpeech(String text,int msgId) async {
    setState(() {
      _isProcessingSpeech = true;
      _playingMessageId = msgId; // Set the current playing message ID
    });

    final String apiUrl = "https://api.openai.com/v1/audio/speech";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "tts-1",
          "voice": "alloy",
          "input": text,
        }),
      );

      if (response.statusCode == 200) {
        final file = File('${Directory.systemTemp.path}/speech.mp3');
        await file.writeAsBytes(response.bodyBytes);

        // Play audio using AudioPlayer
        await _audioPlayer.play(DeviceFileSource(file.path));

        setState(() {
          _isPlayingAudio = true; // Audio is now playing
        });

        // Listen for when the audio completes
        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            _isPlayingAudio = false; // Audio has stopped
            _playingMessageId = null;
          });
        });
      } else {
        throw Exception("Failed to generate speech: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating speech: $e")),
      );
    } finally {
      setState(() {
        _isProcessingSpeech = false;
      });
    }
  }



  void stopSpeech() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlayingAudio = false;
      _playingMessageId = null;
    });
  }



  Future<void> _saveConversation(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMessages = jsonEncode(messages);
    if (currentConversationIndex == null) {
      conversationHistory.add({
        'title': title,
        'messages': jsonMessages,
      });
      prefs.setStringList(
        'conversations',
        conversationHistory.map((conv) => jsonEncode(conv)).toList(),
      );
    } else {
      conversationHistory[currentConversationIndex!] = {
        'title': title,
        'messages': jsonMessages,
      };
      prefs.setStringList(
        'conversations',
        conversationHistory.map((conv) => jsonEncode(conv)).toList(),
      );
    }
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
      messages.add({"id": _messageIdCounter++,"role": "user", "content": message, "isImage": false});
      _controller.clear(); // Clear the TextField
    });
    showSuggestions = false;

    if (isStructuredConversation && currentConversationFlow != null) {
      // Store the user's response
      String key = currentConversationFlow![currentQuestionIndex]["key"]!;
      userResponses[key] = message;

      currentQuestionIndex++;

      if (currentQuestionIndex < currentConversationFlow!.length) {
        // Ask the next question
        setState(() {
          messages.add({
            "id": _messageIdCounter++,
            "role": "assistant",
            "content": currentConversationFlow![currentQuestionIndex]["question"]!,
            "isImage": false,
          });
        });
      } else {
        // All questions are answered, build the prompt and send to OpenAI
        isStructuredConversation = false;
        currentConversationFlow = null;
        currentQuestionIndex = 0;
        await sendStructuredPromptToGPT();
      }
    } else {
      // Regular conversation handling
      try {
        setState(() {
          _isProcessing = true;
        });
        final response = await _sendTextRequestToGPT(message);

        setState(() {
          messages.add({
            "id": _messageIdCounter++,
            "role": "assistant",
            "content": response,
            "isImage": false,
          });
        });

        // Save the conversation
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
      } catch (error) {
        _showErrorSnackBar("Failed to send message: $error");
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> sendStructuredPromptToGPT() async {
    // Build the prompt based on the collected userResponses
    String prompt = "";

    if (userResponses.containsKey('income') &&
        userResponses.containsKey('fixedExpenses') &&
        userResponses.containsKey('variableExpenses')&&
        userResponses.containsKey('debtQa')

    ) {
      prompt = "Create a budget like you will need to balance the spendings of the user, like reccomend how does user spend their money on based on the following:\n";
      prompt += "Total Monthly Income: ${userResponses['income']}\n";
      prompt += "Fixed Monthly Expenses: ${userResponses['fixedExpenses']}\n";
      prompt +=
      "Variable Monthly Expenses: ${userResponses['variableExpenses']}\n";
      prompt += "Paying loans or debts?: ${userResponses['debtQa']}\n";
    } else if (userResponses.containsKey('totalMonthlyIncomeAfterTaxes') &&
        userResponses.containsKey('transportationAllocation') &&
        userResponses.containsKey('additionalIncomeSources') &&
        userResponses.containsKey('subscriptionsOrMemberships') &&
        userResponses.containsKey('monthlyGroceries') &&
        userResponses.containsKey('cutbackAreas'))
    {
      prompt =
      "Analyze my spending habits and identify areas where I can cut back, you will need to balance the spending of the user, like recommend how does user spend their money based on the following information:\n";
      prompt += "Total Monthly Income After Taxes: ${userResponses['totalMonthlyIncomeAfterTaxes']}\n";
      prompt += "Transportation Allocation: ${userResponses['transportationAllocation']}\n";
      prompt += "Additional Income Sources: ${userResponses['additionalIncomeSources']}\n";
      prompt += "Subscriptions or Memberships: ${userResponses['subscriptionsOrMemberships']}\n";
      prompt += "Monthly Groceries: ${userResponses['monthlyGroceries']}\n";
      prompt += "Cutback Areas: ${userResponses['cutbackAreas']}\n";

    } else if (userResponses.containsKey('savingsGoal') &&
        userResponses.containsKey('goalMonths') &&
        userResponses.containsKey('monthlySavings')) {
      prompt =
      "Set up a savings goal and create a plan to reach it based on the following information:\n";
      prompt += "Savings Goal Amount: ${userResponses['savingsGoal']}\n";
      prompt += "Goal Timeline (Months): ${userResponses['goalMonths']}\n";
      prompt +=
      "Monthly Savings Amount: ${userResponses['monthlySavings']}\n";
    } else {
      prompt = "Assist me with the following information:\n";
      userResponses.forEach((key, value) {
        prompt += "$key: $value\n";
      });
    }

    try {
      setState(() {
        _isProcessing = true;
      });
      final response = await _sendTextRequestToGPT(prompt);

      setState(() {
        messages.add({
          "id": _messageIdCounter++,
          "role": "assistant",
          "content": response,
          "isImage": false,
        });
      });

      // Save the conversation
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
    } catch (error) {
      _showErrorSnackBar("Failed to send structured prompt: $error");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }



  Future<String> _sendTextRequestToGPT(String message) async {
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
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content": "You're a finance assistance app, based in the Philippines. Your goal is to help users manage their finances. Keep your responses concise and clear. Politely decline if the user asks for topics unrelated to finance."
            },
            ...messages.map((msg) {
              if (msg['isImage'] == true && msg['role'] == 'user') {
                return {
                  "role": "user",
                  "content": msg['content'], // Use the placeholder string
                };
              } else {
                return {
                  "role": msg['role'],
                  "content": msg['content'], // Ensure this is always a string
                };
              }
            }).toList(),
            // Add the user's new message
            {
              "role": "user",
              "content": message,
            },
          ],
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
          "model": "gpt-4",
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

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _showInputField = false;
        _isUploadingImage = true; // Hide the input field
      });
      _selectedImage = File(pickedFile.path);
      await analyzeImage(_selectedImage!);
      // No need to set _isUploadingImage to false here
    }
  }


  Future<void> analyzeImage(File image) async {
    setState(() {
      messages.add({
        "id": _messageIdCounter++,
        "role": "user",
        "content": "Please analyze this image.", // Use a placeholder string
        "isImage": true,
        "imageFile": image, // Store the File object here
      });
      _isProcessing = true;
    });

    try {
      final analysisResult = await _sendImageToGPT4(image);

      setState(() {
        messages.add({
          "id": _messageIdCounter++,
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
        _isUploadingImage = false; // Show the input field again
      });
    }
  }





  Future<String> _sendImageToGPT4(File image) async {
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
          "model": "gpt-4o",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "What is in this image?list every prices you will see and the total amount",
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  },
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

  Future<void> _listen() async {
    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }




  // New method to start recording
  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _audioFilePath = '${directory.path}/audio.wav';

    await _audioRecorder.startRecorder(
      toFile: _audioFilePath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      _isRecording = true;
    });
  }

  // New method to stop recording and send audio to OpenAI
  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    // Send audio file to OpenAI API
    await _sendAudioToOpenAI();
  }

  // Method to send audio to OpenAI Whisper API and retrieve transcription
  Future<void> _sendAudioToOpenAI() async {
    final audioFile = File(_audioFilePath);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
    );

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));
    request.fields['model'] = 'whisper-1';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final transcription = json.decode(responseBody)['text'];

      setState(() {
        // Update the text field with the transcription
        _controller.text = transcription;
      });
    } else {
      setState(() {
        _transcription = 'Failed to transcribe audio';
      });
    }
  }







  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Remove _speech.stop() since we're not using speech_to_text anymore
    // _speech.stop();
    _audioRecorder.closeRecorder();
    _audioPlayer.dispose(); // Dispose of the audio player
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
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                messages = [];
                currentConversationIndex = null;
                showSuggestions = true;
                isStructuredConversation = false;
                currentConversationFlow = null;
                currentQuestionIndex = 0;
                userResponses = {};
                _showInputField = true;
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
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.lightBlue,
              alignment: Alignment.center,
              child: const Text(
                "Chat History",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                        currentConversationIndex =
                            conversationHistory.indexOf(conversation);
                        messages = List<Map<String, dynamic>>.from(
                          jsonDecode(conversation['messages']),
                        );
                        showSuggestions = false;
                        isStructuredConversation = false;
                        currentConversationFlow = null;
                        currentQuestionIndex = 0;
                        userResponses = {};
                      });
                      Navigator.pop(context);
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
                      'images/finedger_logo.png', // Path to your logo.png
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
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.blue[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: msg['isImage']
                            ? (isUserMessage
                            ? Image.file(
                          msg['imageFile'], // Use 'imageFile' to display the image
                          height: 150,
                          width: 150,
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.file(
                              msg['content'],
                              height: 150,
                              width: 150,
                            ),
                            // Add icons if needed
                          ],
                        ))
                            : Column(
                          crossAxisAlignment: isUserMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['content'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16.0,
                              ),
                              textAlign:
                              isUserMessage ? TextAlign.right : TextAlign.left,
                            ),
                            if (msg['role'] == 'assistant')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Volume Icon
                                  IconButton(
                                    icon: Icon(
                                      _playingMessageId == msg['id']
                                          ? Icons.stop
                                          : Icons.volume_up,
                                    ),
                                    onPressed: () {
                                      if (_playingMessageId == msg['id']) {
                                        stopSpeech();
                                      } else {
                                        generateSpeech(msg['content'], msg['id']);
                                      }
                                    },
                                  ),
                                  // Copy Icon
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: msg['content']));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Copied to clipboard")),
                                      );
                                    },
                                  ),
                                  // Share Icon
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      Share.share(msg['content']);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),


              if (_isProcessing || _isProcessingSpeech)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),

              if (_isRecording)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Recording...',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Input Field
              if (_showInputField)
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_isProcessing,
                          decoration: InputDecoration(
                            hintText: "Enter your message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 1.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image),
                                    onPressed: pickImage,
                                    tooltip: "Pick an image",
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isRecording ? Icons.mic : Icons.mic_none,
                                      color: _isRecording ? Colors.red : null,
                                    ),
                                    onPressed: _listen,
                                    tooltip: _isRecording
                                        ? "Stop recording"
                                        : "Start recording",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isProcessing
                            ? null
                            : () {
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
          if (showSuggestions && !isStructuredConversation)
            Positioned(
              bottom: 70,
              right: 10,
              left: 10,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: floatingSuggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Initialize the structured conversation
                            currentConversationFlow =
                            conversationFlows[suggestion];
                            currentQuestionIndex = 0;
                            userResponses = {};
                            isStructuredConversation = true;
                            messages.add({
                              "id": _messageIdCounter++,
                              "role": "assistant",
                              "content":
                              currentConversationFlow![currentQuestionIndex]
                              ["question"]!,
                              "isImage": false,
                            });
                          });
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
