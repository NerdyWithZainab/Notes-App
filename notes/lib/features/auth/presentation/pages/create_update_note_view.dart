import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes/utilities/generics/get_arguments.dart';
import 'package:notes/features/notes/data/models/cloud_note.dart';
import 'package:notes/injection_container.dart';
import 'package:notes/features/notes/presentation/controllers/notes_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final TextEditingController _textController;
  late final NotesController _controller;

  // Translation Variables
  Map<String, String> noteLanguages = {}; // Store language per note
  String _translatedText = '';
  bool _isTranslating = false; // Loading spinner control // default

  // Available languages
  final Map<String, String> languages = {
    'en': 'English',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'zh': 'Chinese',
  };

  @override
  void initState() {
    _textController = TextEditingController();
    _controller = ServiceLocator().notesController;
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _controller.updateText(note.documentId, text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final created = await _controller.create(userId);
    final newNote = CloudNote(
      documentId: created.id,
      ownerUserId: created.ownerUserId,
      text: created.text,
      isPinned: created.isPinned,
    );
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _controller.delete(note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _controller.updateText(note.documentId, text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  // --- Translation code ---
  Future<void> translateText(
      String originalText, String sourceLang, String targetLang) async {
    setState(() {
      _isTranslating = true;
    });
    try {
      final response = await http
          .post(
        Uri.parse('http://192.168.1.122:5000/translate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text': originalText,
          'source_lang': sourceLang,
          'target_lang': targetLang,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('The request timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _translatedText = responseData['translation'];
          _textController.text = _translatedText;
        });
      } else if (response.statusCode == 405) {
        throw Exception(
            'Method not allowed. Please check server configuration.');
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _translatedText =
              'Translation failed: ${errorData['error'] ?? response.body}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Translation failed: ${errorData['error'] ?? response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException {
      setState(() {
        _translatedText = 'Translation timed out. Please try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Translation timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Error: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  Future<void> _showLanguageSelectionDialog(String text) async {
    String selectedSource = 'en';
    String selectedTarget = 'fr';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple.shade200,
          title: const Text('Select Languages',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSource,
                dropdownColor: Colors.deepPurple.shade200,
                decoration: const InputDecoration(labelText: 'Source Language'),
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedSource = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTarget,
                dropdownColor: Colors.deepPurple.shade200,
                decoration: const InputDecoration(labelText: 'Target Language'),
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedTarget = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isTranslating = true;
                });
                await translateText(
                  text,
                  languages[selectedSource]!,
                  languages[selectedTarget]!,
                );
                setState(() {
                  _isTranslating = false;
                });
              },
              child: const Text('Translate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          context.loc.note,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (text.isNotEmpty) {
                await _showLanguageSelectionDialog(text);
              }
            },
            icon: const Icon(Icons.translate),
          ),
        ],
        backgroundColor: Colors.deepPurple.shade600,
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(16),
                  child: _isTranslating
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: context.loc.start_typing_your_note,
                            hintStyle: const TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
