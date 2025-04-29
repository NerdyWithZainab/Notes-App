import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes/utilities/generics/get_arguments.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  // Translation Variables
  Map<String, String> noteLanguages = {}; // Store language per note
  String _translatedText = '';
  bool _isTranslating = false; // Loading spinner control
  String _selectedSourceLang = 'en'; // default
  String _selectedTargetLang = 'fr'; // default

  // Available languages
  final Map<String, String> languages = {
    'en': 'English',
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'zh': 'Chinese',
    // Add more languages if your Hugging Face model supports
  };

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
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
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  // --- Your New Translation Code ---

  // Async function that updates the translated text directly in state
  // --- Translation Function ---
  Future<void> translateText(
      String originalText, String sourceLang, String targetLang) async {
    setState(() {
      _isTranslating = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.122:5000/translate'), // Your Flask server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': originalText,
          'source_lang': sourceLang,
          'target_lang': targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _translatedText = responseData['translation'];
          _textController.text = _translatedText; // Update note
        });
      } else {
        setState(() {
          _translatedText = 'Translation failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

// --- UI Building Starts ---
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
                setState(() {
                  _isTranslating = true; // Start loading when translating
                });

                await translateText(
                  text,
                  'en', // Source language (English)
                  'fr', // Target language (French)
                );

                setState(() {
                  _textController.text =
                      _translatedText; // Update the note text
                  _isTranslating = false; // Stop loading
                });
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
