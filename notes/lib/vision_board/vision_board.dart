import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(PinterestApp());
}

class PinterestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Recommendations',
      home: ImageSearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageSearchPage extends StatefulWidget {
  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _imageUrls = [];
  bool _loading = false;

  Future<void> _searchImages(String query) async {
    setState(() {
      _loading = true;
      _imageUrls.clear();
    });

    final uri =
        Uri.parse('http://localhost:5000/search?query=$query&num_images=10');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _imageUrls = List<String>.from(data.map((img) => img['url']));
        _loading = false;
      });
    } else {
      print("Failed to load images: ${response.statusCode}");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pinterest-style Image Search"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for images...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchImages(_controller.text),
                  child: Text("Search"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: EdgeInsets.all(8),
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(_imageUrls[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
