import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TranslationPage(),
    );
  }
}

class TranslationPage extends StatefulWidget {
  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _textController = TextEditingController();
  String _sourceLang = 'English';
  String _targetLang = 'French';
  String _translatedText = '';

  Future<void> translateText() async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/translate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'text': _textController.text,
        'source_lang': _sourceLang,
        'target_lang': _targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        _translatedText = responseData['translation'];
      });
    } else {
      setState(() {
        _translatedText = 'Translation failed: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Language Translation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: "Enter text to translate"),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _sourceLang,
              onChanged: (String? newValue) {
                setState(() {
                  _sourceLang = newValue!;
                });
              },
              items: <String>['English', 'French', 'Spanish', 'German']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text('Select source language'),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _targetLang,
              onChanged: (String? newValue) {
                setState(() {
                  _targetLang = newValue!;
                });
              },
              items: <String>['English', 'French', 'Spanish', 'German']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text('Select target language'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: translateText,
              child: Text('Translate'),
            ),
            SizedBox(height: 20),
            Text(
              'Translated Text: $_translatedText',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
