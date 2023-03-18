import 'dart:async';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // To get text from textfield I have create controller.
  final TextEditingController _controller = TextEditingController();
  // Create a list
  final List<ChatMessage> _message = [];

  String apiKey = "Your API-KEY";
  Future<void> _sendMessage() async {
    ChatMessage message = ChatMessage(text: _controller.text, sender: "user");

    setState(() {
      _message.insert(0, message);
    });

    _controller.clear();

    final response = await generateText(message.text);

    ChatMessage botMessage =
        ChatMessage(text: response.toString(), sender: "bot");

    setState(() {
      _message.insert(0, botMessage);
    });
  }

  Future<String> generateText(String prompt) async {
    try {
      Map<String, dynamic> requestBody = {
        "model": "text-davinci-003",
        "prompt": prompt,
        "temperature": 0,
        "max_tokens": 100,
      };
      // Post Api Url
      var url = Uri.parse('https://api.openai.com/v1/completions');

      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer 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"
          },
          body: json.encode(requestBody)); // post call

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        return responseJson["choices"][0]["text"];
      } else {
        return "Failed to generate text: ${response.body}";
      }
    } catch (e) {
      return "Failed to generate text: $e";
    }
  }

  Widget _buidTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration.collapsed(hintText: "Send a message"),
          ),
        ),
        IconButton(
            onPressed: () {
              _sendMessage();
            },
            icon: Icon(Icons.send))
      ],
    ).px12();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        centerTitle: true,
        title: Text("ChatGPT App"),
      ),
      // body
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              padding: Vx.m8,
              reverse: true,
              itemBuilder: (context, index) {
                return _message[index];
              },
              itemCount: _message.length,
            )),
            Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(),
              child: _buidTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
